import controlP5.*;
import java.util.ArrayList;

int[] arr = {5, 10, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 115, 125}; // Sorted array
int left = 0;
int right = arr.length - 1;
int mid;
int target = 70;
boolean searchStarted = false;
boolean searchComplete = false;
ControlP5 cp5;
Textfield targetTextfield;
Textlabel statusLabel;
Slider speedSlider;
int animationSpeed = 10; // Default animation speed
int previousMillis = 0; // For animation timing
int interval = 2000; // Interval between frames (increase this for slower animation)

void setup() {
  size(1200, 900); // Screen size
  noStroke();

  cp5 = new ControlP5(this);
  
  PFont customFont = createFont("Arial", 24);
  
  // Textfield for changing target value
  targetTextfield = cp5.addTextfield("targetTextfield")
                       .setPosition(10, height - 175)
                       .setSize(250, 50)
                       .setLabel("Target")
                       .setText("70")
                       .setColor(color(0, 0, 0))
                       .setColorBackground(color(220, 220, 220))
                       .setColorActive(color(0, 150, 255))
                       .setFont(customFont);

  // Slider for adjusting animation speed
  speedSlider = cp5.addSlider("speedSlider")
                  .setPosition(270, height - 175)
                  .setSize(250, 50)
                  .setRange(1, 20) // Adjust range as needed
                  .setValue(10)
                  .setLabel("Speed")
                  .setColorLabel(color(0, 0, 0))
                  .setColorActive(color(0, 150, 255))
                  .setFont(customFont);

  statusLabel = cp5.addTextlabel("statusLabel")
                   .setPosition(10, height - 50) 
                   .setSize(800, 30)
                   .setColor(color(0, 0, 0))
                   .setText("");
                   
  // Reset button
  cp5.addButton("resetButton")
     .setPosition(width - 150, height - 80)
     .setSize(130, 50)
     .setLabel("Reset")
     .setFont(customFont);

  // Start button
  cp5.addButton("startButton")
     .setPosition(width - 300, height - 80)
     .setSize(130, 50)
     .setLabel("Start")
     .setFont(customFont);
}

void draw() {
  background(255);
  int barWidth = width / arr.length;

  animationSpeed = (int) speedSlider.getValue();
  interval = 2000 / animationSpeed; // Adjust interval based on slider value

  // Drawing the bars
  fill(255);
  rect(0, 0, width, height - 200);

  for (int i = 0; i < arr.length; i++) {
    if (i == mid) {
      fill(255, 0, 0); // Highlight the middle element
    } else if (i >= left && i <= right) {
      fill(200, 200, 100); // Highlight the current search interval
    } else {
      fill(100, 150, 250); // Default color
    }
    rect(i * barWidth, height - 200 - arr[i] * 3, barWidth - 1, arr[i] * 3);
  }

  fill(240);
  rect(0, height - 100, width, 100);

  fill(0);
  textSize(18);
  text("Current Interval: [" + left + ", " + right + "]", 10, height - 20);
  text("Target: " + targetTextfield.getText(), 10, height - 40);
  text("Status: " + (searchComplete ? "Completed" : "Searching"), 10, height - 60);
  cp5.draw();

  // Binary search logic
  if (searchStarted && !searchComplete) {
    int currentMillis = millis();
    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;
      
      int targetValue = parseInt(targetTextfield.getText());

      if (left <= right) {
        mid = (left + right) / 2;
        if (arr[mid] == targetValue) {
          searchComplete = true;
        } else if (arr[mid] < targetValue) {
          left = mid + 1;
        } else {
          right = mid - 1;
        }
      } else {
        searchComplete = true;
      }
    }
  }

  delay(10); // Small delay to slow down the draw loop
}

void resetButton() {
  reset();
}

void startButton() {
  searchStarted = true;
  searchComplete = false;
  left = 0;
  right = arr.length - 1;
  previousMillis = millis(); // Reset timing
}

void reset() {
  searchStarted = false;
  searchComplete = false;
  left = 0;
  right = arr.length - 1;
  previousMillis = millis(); // Reset timing
}
