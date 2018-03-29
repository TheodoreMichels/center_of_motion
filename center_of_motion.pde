// Simple utility to track the center of motion from an attached video capture device.
// Theodore Michels 2018

// Based on:
// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Exercise 16-7: Create a sketch that looks for the average location 
// of motion. Can you have an ellipse follow your waving hand?

/* DEPENDENCIES */
import processing.video.*;
import netP5.*;
import oscP5.*;

/* SETTINGS */
int broadcastPort = 14000;
String remoteIP = "127.0.0.1";
// How different must a pixel be to be a "motion" pixel
float threshold = 50;
// Linear interpolation percentage
float smoothing = 0.1;

// Resolution of tracking device
int camWidth = 640;
int camHeight = 360;

// Output the coordinates as a percentage (0 - 1 float) of the video, rather than absolute pixels
boolean outputPercent = true;

// Is the data just being sent somewhere else?
boolean headless = false;
// Send the data via OSC
boolean broadcast = true;
// Show the simple debug visualization
boolean debug = true;
// Display the camera feed?
boolean displayVideo = true;

// Global tracking variables
float avgX = 0; // Average of motion X
float avgY = 0; // Average of motion Y
float lerpX = 0;
float lerpY = 0;

OscP5 oscP5;
NetAddress remoteLocation;
// Variable for capture device
Capture video;
// Previous Frame
PImage prevFrame;

// Using settings allows the "size()" to be variable
void settings() {

  if (headless) {
    displayVideo = false;
    size(1, 1);
  } else {
    size(camWidth, camHeight);
  }
}

void setup() {
  oscP5 = new OscP5(this, 12000);
  remoteLocation = new NetAddress(remoteIP, broadcastPort);
  printArray(Capture.list());

  // Using the default capture device
  video = new Capture(this, camWidth, camHeight);
  video.start();

  // Create an empty image the same size as the video
  prevFrame = createImage(video.width, video.height, RGB);
}

// When a new frame is available...
void captureEvent(Capture video) {
  // Save the previous frame.
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  prevFrame.updatePixels();  

  // Now read the next frame.
  video.read();
}


void draw() {

  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();

  // These are the variables we'll need to find the average X and Y
  float sumX = 0;
  float sumY = 0;

  int motionCount = 0; 

  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      // What is the current color
      color current = video.pixels[x+y*video.width];

      // What is the previous color
      color previous = prevFrame.pixels[x+y*video.width];

      // Step 4, compare colors (previous vs. current)
      float r1 = red(current); 
      float g1 = green(current);
      float b1 = blue(current);
      float r2 = red(previous); 
      float g2 = green(previous);
      float b2 = blue(previous);

      // Motion for an individual pixel is the difference between the previous color and current color.
      float diff = dist(r1, g1, b1, r2, g2, b2);

      // If greater than the threshold, add the coordinate to the sum.
      if (diff > threshold) {
        sumX += x;
        sumY += y;
        motionCount++;
      }
    }
  }

  if (motionCount > 200) {
    // average location is total location divided by the number of motion pixels.
    avgX = sumX / motionCount; 
    avgY = sumY / motionCount;
  }

  // Smooth out the motion
  lerpX = lerp(lerpX, avgX, smoothing);
  lerpY = lerp(lerpY, avgY, smoothing);

  // Render the visuals
  if (!headless) {
    visuals();
    if (debug) {
      debug();
    }
  }

  if (broadcast) {
    if (outputPercent) {
      oscP5.send(new OscMessage("/x/" + lerpX/video.width), remoteLocation);
      oscP5.send(new OscMessage("/y/" + lerpY/video.height), remoteLocation);
      //println("X: " + lerpX/video.width + " Y: " + lerpY/video.height);
    } else {
      oscP5.send(new OscMessage("/x/" + lerpX), remoteLocation);
      oscP5.send(new OscMessage("/y/" + lerpY), remoteLocation);
      //println("X: " + lerpX + " Y: " + lerpY);
    }
  }
}

// Visualize the motion
void debug() {

  if (displayVideo) {
    image(video, 0, 0);
  }

  stroke(0, 255, 0);
  fill(255, 0, 0);
  ellipse(lerpX, lerpY, 20, 20);
}

void visuals() {
  background(0);

  // Put your visuals here...
}