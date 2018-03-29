// Based on:

// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Exercise 16-7: Create a sketch that looks for the average location 
// of motion. Can you have an ellipse follow your waving hand?   

import processing.video.*;

// Variable for capture device
Capture video;
// Previous Frame
PImage prevFrame;

// How different must a pixel be to be a "motion" pixel
float threshold = 50;
// Linear interpolation percentage
float smoothing = 0.1;

float lerpX = 0;
float lerpY = 0;

float avgX = 0;
float avgY = 0;

int camWidth = 1280;
int camHeight = 720;

// Output the coordinates as a percentage (0 - 1 float) of the video, rather than absolute pixels
boolean outputPercent = true;

boolean headless = false;
boolean displayVideo = true;

void settings(){
  if(headless){
    displayVideo = false;
    size(1, 1);
  }else{
    size(camWidth, camHeight);
  }
}

void setup() {
  
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
  if(!headless){
    visuals();
  }
  
  if(outputPercent){
    println("X: " + lerpX/video.width + "% Y: " + lerpY/video.height + "%");
  }else{
    println("X: " + lerpX + " Y: " + lerpY);
  }
  
}

// Just to separate things a bit.
void visuals(){
  background(0);
  // You don't need to display it to analyze it!
  if(displayVideo){
    image(video, 0, 0);
  }
  
  smooth();
  noStroke();
  fill(255, 0, 0);
  ellipse(lerpX, lerpY, 16, 16);
}