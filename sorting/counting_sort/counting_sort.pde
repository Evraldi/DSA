// Counting Sort Visualization
// This visualizer demonstrates the counting sort algorithm, which sorts integers by counting occurrences

int[] arr;
int n = 15; // Default array size
boolean sorted = false;
boolean paused = false;
int steps = 0;
float animationProgress = 0;
boolean isAnimating = false;
int currentSpeed = 10;

// Counting sort specific variables
int[] countArray; // Count array for counting occurrences
int[] outputArray; // Output array for sorted elements
int minValue = 0; // Minimum value in the array
int maxValue = 0; // Maximum value in the array
int currentPhase = 0; // 0: counting, 1: calculating positions, 2: placing elements
int currentElement = 0; // Current element being processed
int currentCount = 0; // Current count being processed

// UI Panel dimensions
int panelWidth = 300;
int panelHeight = 650; // Even taller panel for better button spacing
int panelX, panelY;

// Button dimensions
int buttonWidth = 80;
int buttonHeight = 40;
int buttonSpacing = 10;

// Buttons
int resetX, resetY;
boolean resetHover = false;

// Stop button
int stopX, stopY;
boolean stopHover = false;

// Size control buttons
int decreaseSizeX, decreaseSizeY;
int increaseSizeX, increaseSizeY;
boolean decreaseSizeHover = false;
boolean increaseSizeHover = false;

// Speed control buttons
int decreaseSpeedX, decreaseSpeedY;
int increaseSpeedX, increaseSpeedY;
boolean decreaseSpeedHover = false;
boolean increaseSpeedHover = false;

// Visualization areas
int arrayViewX, arrayViewY;
int arrayViewWidth, arrayViewHeight;
int countViewX, countViewY;
int countViewWidth, countViewHeight;
int outputViewX, outputViewY;
int outputViewWidth, outputViewHeight;

void setup() {
  // Use fullScreen() instead of size() to open in full screen mode
  fullScreen();
  panelX = width - panelWidth - 20;
  panelY = 20;

  // Position all buttons with fixed pixel positions relative to panel
  // Calculate button positions with proper spacing
  int labelHeight = 40; // Height for labels above buttons

  // Array Size buttons - top row
  decreaseSizeX = panelX + 50;
  decreaseSizeY = panelY + 400; // Even more space from top
  increaseSizeX = panelX + 170; // Increased spacing between buttons
  increaseSizeY = panelY + 400;

  // Animation Speed buttons - middle row
  decreaseSpeedX = panelX + 50;
  decreaseSpeedY = panelY + 480; // Much more vertical spacing between rows (100px)
  increaseSpeedX = panelX + 170; // Increased spacing between buttons
  increaseSpeedY = panelY + 480;

  // Reset and Pause buttons - bottom row
  resetX = panelX + 50;
  resetY = panelY + 580; // Much more vertical spacing between rows (100px)
  stopX = panelX + 170; // Increased spacing between buttons
  stopY = panelY + 580;

  // Set up visualization areas with more space
  arrayViewX = 20;
  arrayViewY = 20;
  arrayViewWidth = width - panelWidth - 60;
  arrayViewHeight = 200;

  countViewX = 20;
  countViewY = arrayViewY + arrayViewHeight + 40;
  countViewWidth = width - panelWidth - 60;
  countViewHeight = 200;

  outputViewX = 20;
  outputViewY = countViewY + countViewHeight + 40;
  outputViewWidth = width - panelWidth - 60;
  outputViewHeight = 200;

  resetArray();
}

void resetArray() {
  // Keep the current array size
  arr = new int[n];
  for (int k = 0; k < n; k++) {
    arr[k] = int(random(1, 30)); // Values between 1 and 30 for better visualization
  }

  // Find minimum and maximum values
  minValue = arr[0];
  maxValue = arr[0];
  for (int i = 1; i < n; i++) {
    if (arr[i] < minValue) minValue = arr[i];
    if (arr[i] > maxValue) maxValue = arr[i];
  }

  // Initialize count array and output array
  countArray = new int[maxValue - minValue + 1];
  outputArray = new int[n];

  // Reset counting sort variables
  currentPhase = 0;
  currentElement = 0;
  currentCount = 0;

  // Reset counters
  sorted = false;
  steps = 0;
  isAnimating = false;

  // Keep the current speed setting
  frameRate(currentSpeed);
}

void draw() {
  background(240);

  // Draw array view
  drawArrayView();

  // Draw count array view
  drawCountView();

  // Draw output array view
  drawOutputView();

  // Update sorting algorithm
  updateSorting();

  // Draw information panel
  drawInfoPanel();

  // Draw buttons
  drawButtons();

  // Draw controls legend
  drawControlsLegend();
}

void drawArrayView() {
  // Draw array view background
  fill(255, 255, 255, 50);
  stroke(70, 130, 180);
  strokeWeight(1);
  rect(arrayViewX, arrayViewY, arrayViewWidth, arrayViewHeight, 5);

  // Draw array title
  fill(25, 25, 112);
  textSize(18); // Larger title text
  textAlign(LEFT, TOP);
  text("Input Array", arrayViewX + 10, arrayViewY + 10);

  // Calculate bar dimensions
  int barWidth = min(arrayViewWidth / n, 80); // Limit maximum bar width
  int maxBarHeight = arrayViewHeight - 80; // More space for labels

  // Calculate the starting x position to center the bars
  int startX = arrayViewX + (arrayViewWidth - (barWidth * n)) / 2;

  // Draw array bars
  for (int k = 0; k < n; k++) {
    // Calculate bar height proportional to value
    int barHeight = int(map(arr[k], minValue, maxValue, 30, maxBarHeight)); // Minimum bar height

    // Determine the color based on the current state
    if (sorted) {
      fill(0, 200, 0); // Green for sorted array
    } else if (currentPhase == 0 && k == currentElement) {
      fill(255, 165, 0); // Orange for current element being counted
    } else if (currentPhase == 2 && k == currentElement) {
      fill(255, 165, 0); // Orange for current element being placed
    } else {
      fill(100, 149, 237); // Blue for normal elements
    }

    // Draw the bar
    int x = startX + k * barWidth;
    int y = arrayViewY + 50 + (maxBarHeight - barHeight); // More space from top
    rect(x, y, barWidth - 4, barHeight); // More space between bars

    // Show array values above the bar
    fill(0);
    textSize(min(14, barWidth - 6)); // Larger text
    textAlign(CENTER, BOTTOM);
    text(arr[k], x + barWidth / 2, y - 5);

    // Show index below the bar
    fill(100);
    textSize(min(12, barWidth - 8));
    textAlign(CENTER, TOP);
    text("[" + k + "]", x + barWidth / 2, arrayViewY + 50 + maxBarHeight + 5);
  }
}

void drawCountView() {
  // Draw count view background
  fill(255, 255, 255, 50);
  stroke(70, 130, 180);
  strokeWeight(1);
  rect(countViewX, countViewY, countViewWidth, countViewHeight, 5);

  // Draw count title
  fill(25, 25, 112);
  textSize(18); // Larger title text
  textAlign(LEFT, TOP);
  text("Count Array", countViewX + 10, countViewY + 10);

  // Calculate count bar dimensions
  int range = maxValue - minValue + 1;
  int barWidth = min(countViewWidth / range, 60); // Limit maximum bar width
  int maxBarHeight = countViewHeight - 80; // More space for labels

  // Calculate the starting x position to center the bars
  int startX = countViewX + (countViewWidth - (barWidth * range)) / 2;

  // Draw count bars
  for (int i = 0; i < range; i++) {
    int value = i + minValue; // The actual value this count represents

    // Calculate bar height proportional to count
    int maxCount = 0;
    for (int count : countArray) {
      if (count > maxCount) maxCount = count;
    }
    maxCount = max(maxCount, 1); // Avoid division by zero

    int barHeight = int(map(countArray[i], 0, maxCount, 10, maxBarHeight)); // Minimum bar height

    // Determine the color based on the current state
    if (currentPhase == 0 && value == arr[currentElement]) {
      fill(255, 165, 0); // Orange for current count being updated
    } else if (currentPhase == 1 && i == currentCount) {
      fill(255, 165, 0); // Orange for current count being processed
    } else {
      fill(100, 149, 237); // Blue for normal counts
    }

    // Draw the bar
    int x = startX + i * barWidth;
    int y = countViewY + 50 + (maxBarHeight - barHeight); // More space from top
    rect(x, y, barWidth - 4, barHeight); // More space between bars

    // Show count value above the bar
    fill(0);
    textSize(min(14, barWidth - 6)); // Larger text
    textAlign(CENTER, BOTTOM);
    text(countArray[i], x + barWidth / 2, y - 5);

    // Show the value this count represents below the bar
    fill(100);
    textSize(min(12, barWidth - 8));
    textAlign(CENTER, TOP);
    text(value, x + barWidth / 2, countViewY + 50 + maxBarHeight + 5);
  }
}

void drawOutputView() {
  // Draw output view background
  fill(255, 255, 255, 50);
  stroke(70, 130, 180);
  strokeWeight(1);
  rect(outputViewX, outputViewY, outputViewWidth, outputViewHeight, 5);

  // Draw output title
  fill(25, 25, 112);
  textSize(18); // Larger title text
  textAlign(LEFT, TOP);
  text("Output Array", outputViewX + 10, outputViewY + 10);

  // Calculate bar dimensions
  int barWidth = min(outputViewWidth / n, 80); // Limit maximum bar width
  int maxBarHeight = outputViewHeight - 80; // More space for labels

  // Calculate the starting x position to center the bars
  int startX = outputViewX + (outputViewWidth - (barWidth * n)) / 2;

  // Draw output bars
  for (int k = 0; k < n; k++) {
    // Only draw if there's a value in the output array at this position
    if (currentPhase >= 2 && k < currentElement) {
      // Calculate bar height proportional to value
      int barHeight = int(map(outputArray[k], minValue, maxValue, 30, maxBarHeight)); // Minimum bar height

      // Determine the color based on the current state
      if (sorted) {
        fill(0, 200, 0); // Green for sorted array
      } else if (currentPhase == 2 && k == currentElement - 1) {
        fill(255, 165, 0); // Orange for current element being placed
      } else {
        fill(100, 149, 237); // Blue for normal elements
      }

      // Draw the bar
      int x = startX + k * barWidth;
      int y = outputViewY + 50 + (maxBarHeight - barHeight); // More space from top
      rect(x, y, barWidth - 4, barHeight); // More space between bars

      // Show array values above the bar
      fill(0);
      textSize(min(14, barWidth - 6)); // Larger text
      textAlign(CENTER, BOTTOM);
      text(outputArray[k], x + barWidth / 2, y - 5);

      // Show index below the bar
      fill(100);
      textSize(min(12, barWidth - 8));
      textAlign(CENTER, TOP);
      text("[" + k + "]", x + barWidth / 2, outputViewY + 50 + maxBarHeight + 5);
    }
  }
}

void updateSorting() {
  if (!paused && !sorted) {
    if (isAnimating) {
      // Handle animation
      animationProgress += 0.1;
      if (animationProgress >= 1) {
        isAnimating = false;

        // Perform the current step based on the phase
        if (currentPhase == 0) {
          // Counting phase - count occurrences of each element
          countArray[arr[currentElement] - minValue]++;
          currentElement++;

          // If all elements counted, move to next phase
          if (currentElement >= n) {
            currentPhase = 1;
            currentCount = 0;
            steps++;
          }
        } else if (currentPhase == 1) {
          // Calculate positions phase - modify count array to store positions
          if (currentCount > 0) {
            countArray[currentCount] += countArray[currentCount - 1];
          }
          currentCount++;

          // If all counts processed, move to next phase
          if (currentCount >= countArray.length) {
            currentPhase = 2;
            currentElement = n - 1; // Start from the end for stable sort
            steps++;
          }
        } else if (currentPhase == 2) {
          // Placing elements phase - place elements in output array
          int value = arr[currentElement];
          int countIndex = value - minValue;
          countArray[countIndex]--;
          int outputIndex = countArray[countIndex];
          outputArray[outputIndex] = value;

          currentElement--;

          // If all elements placed, sorting is complete
          if (currentElement < 0) {
            // Copy output array back to input array
            for (int i = 0; i < n; i++) {
              arr[i] = outputArray[i];
            }
            sorted = true;
            steps++;
          }
        }

        // Start next animation if not sorted
        if (!sorted) {
          isAnimating = true;
          animationProgress = 0;
        }
      }
    } else {
      // Start the animation
      isAnimating = true;
      animationProgress = 0;
    }
  }
}

void drawInfoPanel() {
  // Draw panel background
  fill(255);
  stroke(70, 130, 180);
  strokeWeight(2);
  rect(panelX, panelY, panelWidth, panelHeight, 10);

  // Draw panel title
  fill(25, 25, 112);
  textSize(20);
  textAlign(CENTER, TOP);
  text("Counting Sort Visualizer", panelX + panelWidth/2, panelY + 15);

  // Draw algorithm information with more line spacing
  textSize(14);
  textAlign(LEFT, TOP);
  fill(0);
  String info = "Counting Sort is a non-comparative\nsorting algorithm that works by\ncounting the occurrences of each\nelement and using that information\nto determine the position of each\nelement in the output array.";
  text(info, panelX + 15, panelY + 45);

  // Add the second paragraph with more spacing
  String info2 = "It is efficient when the range of\ninput values is not significantly\nlarger than the number of elements.";
  text(info2, panelX + 15, panelY + 140); // More space between paragraphs

  // Draw complexity information with much more spacing
  text("Time Complexity: O(n + k)", panelX + 15, panelY + 190); // Increased y-position
  text("Space Complexity: O(n + k)", panelX + 15, panelY + 220); // Increased y-position
  text("where n = array size", panelX + 15, panelY + 250); // Increased y-position
  text("and k = range of values", panelX + 15, panelY + 270); // Increased y-position

  // Draw current metrics with much more spacing
  textAlign(LEFT, TOP);
  text("Steps: " + steps, panelX + 15, panelY + 300); // Increased y-position
  text("Array Size: " + n, panelX + 150, panelY + 300); // Increased y-position
  text("Value Range: " + minValue + " to " + maxValue, panelX + 15, panelY + 325); // Increased y-position
  text("Speed: " + currentSpeed + " fps", panelX + 150, panelY + 325); // Increased y-position

  // Draw current phase
  String phase = "";
  if (currentPhase == 0) phase = "Counting Occurrences";
  else if (currentPhase == 1) phase = "Calculating Positions";
  else if (currentPhase == 2) phase = "Placing Elements";
  else phase = "Sorting Complete";
  text("Current Phase: " + phase, panelX + 15, panelY + 355); // Increased y-position

  // Draw current action
  textAlign(CENTER, BOTTOM);
  fill(0);
  String action = "";
  if (sorted) {
    action = "Array Sorted!";
    fill(0, 150, 0);
  } else if (paused) {
    action = "Paused";
    fill(150, 0, 0);
  } else if (currentPhase == 0) {
    action = "Counting occurrences of each element";
    fill(0, 0, 150);
  } else if (currentPhase == 1) {
    action = "Calculating positions in output array";
    fill(0, 0, 150);
  } else if (currentPhase == 2) {
    action = "Placing elements in output array";
    fill(0, 0, 150);
  }

  // Draw status message in a more prominent way
  fill(25, 25, 112, 200);
  rect(width/2 - 300, height - 50, 600, 40, 10);
  fill(255);
  textSize(18);
  text(action, width/2, height - 25);

  // Draw additional explanation if not sorted
  if (!sorted && !paused) {
    fill(0);
    textSize(14);
    String explanation = "";
    if (currentPhase == 0 && currentElement < n) {
      explanation = "Counting occurrences of element " + arr[currentElement] + " at index " + currentElement;
    } else if (currentPhase == 1 && currentCount < countArray.length) {
      explanation = "Calculating cumulative count for value " + (currentCount + minValue);
    } else if (currentPhase == 2 && currentElement >= 0) {
      explanation = "Placing element " + arr[currentElement] + " from index " + currentElement + " into output array";
    }
    text(explanation, width/2, height - 70);
  }
}

void drawButtons() {
  // Reset button
  if (mouseX >= resetX && mouseX <= resetX + buttonWidth &&
      mouseY >= resetY && mouseY <= resetY + buttonHeight) {
    fill(100, 149, 237); // Hover color
    resetHover = true;
  } else {
    fill(70, 130, 180); // Normal color
    resetHover = false;
  }
  rect(resetX, resetY, buttonWidth, buttonHeight, 5);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Reset", resetX + buttonWidth/2, resetY + buttonHeight/2);

  // Stop button
  if (mouseX >= stopX && mouseX <= stopX + buttonWidth &&
      mouseY >= stopY && mouseY <= stopY + buttonHeight) {
    fill(100, 149, 237); // Hover color
    stopHover = true;
  } else {
    fill(paused ? 220 : 70, paused ? 20 : 130, paused ? 60 : 180); // Red when paused, blue when running
    stopHover = false;
  }
  rect(stopX, stopY, buttonWidth, buttonHeight, 5);
  fill(255);
  textAlign(CENTER, CENTER);
  text(paused ? "Resume" : "Pause", stopX + buttonWidth/2, stopY + buttonHeight/2);

  // Size control buttons
  fill(0);
  textAlign(CENTER, TOP);
  text("Array Size", panelX + panelWidth/2, decreaseSizeY - 30); // Moved label up

  // Decrease size button
  if (mouseX >= decreaseSizeX && mouseX <= decreaseSizeX + buttonWidth &&
      mouseY >= decreaseSizeY && mouseY <= decreaseSizeY + buttonHeight) {
    fill(100, 149, 237); // Hover color
    decreaseSizeHover = true;
  } else {
    fill(70, 130, 180); // Normal color
    decreaseSizeHover = false;
  }
  rect(decreaseSizeX, decreaseSizeY, buttonWidth, buttonHeight, 5);
  fill(255);
  textAlign(CENTER, CENTER);
  text("-", decreaseSizeX + buttonWidth/2, decreaseSizeY + buttonHeight/2);

  // Increase size button
  if (mouseX >= increaseSizeX && mouseX <= increaseSizeX + buttonWidth &&
      mouseY >= increaseSizeY && mouseY <= increaseSizeY + buttonHeight) {
    fill(100, 149, 237); // Hover color
    increaseSizeHover = true;
  } else {
    fill(70, 130, 180); // Normal color
    increaseSizeHover = false;
  }
  rect(increaseSizeX, increaseSizeY, buttonWidth, buttonHeight, 5);
  fill(255);
  textAlign(CENTER, CENTER);
  text("+", increaseSizeX + buttonWidth/2, increaseSizeY + buttonHeight/2);

  // Speed control buttons
  fill(0);
  textAlign(CENTER, TOP);
  text("Animation Speed", panelX + panelWidth/2, decreaseSpeedY - 25);

  // Decrease speed button
  if (mouseX >= decreaseSpeedX && mouseX <= decreaseSpeedX + buttonWidth &&
      mouseY >= decreaseSpeedY && mouseY <= decreaseSpeedY + buttonHeight) {
    fill(100, 149, 237); // Hover color
    decreaseSpeedHover = true;
  } else {
    fill(70, 130, 180); // Normal color
    decreaseSpeedHover = false;
  }
  rect(decreaseSpeedX, decreaseSpeedY, buttonWidth, buttonHeight, 5);
  fill(255);
  textAlign(CENTER, CENTER);
  text("-", decreaseSpeedX + buttonWidth/2, decreaseSpeedY + buttonHeight/2);

  // Increase speed button
  if (mouseX >= increaseSpeedX && mouseX <= increaseSpeedX + buttonWidth &&
      mouseY >= increaseSpeedY && mouseY <= increaseSpeedY + buttonHeight) {
    fill(100, 149, 237); // Hover color
    increaseSpeedHover = true;
  } else {
    fill(70, 130, 180); // Normal color
    increaseSpeedHover = false;
  }
  rect(increaseSpeedX, increaseSpeedY, buttonWidth, buttonHeight, 5);
  fill(255);
  textAlign(CENTER, CENTER);
  text("+", increaseSpeedX + buttonWidth/2, increaseSpeedY + buttonHeight/2);
}

void drawControlsLegend() {
  fill(255);
  stroke(70, 130, 180);
  strokeWeight(1);
  rect(panelX, panelY + panelHeight + 10, panelWidth, 140, 5);

  fill(0);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Controls:", panelX + 10, panelY + panelHeight + 20);
  textSize(14);
  text("P - Pause/Resume", panelX + 10, panelY + panelHeight + 45);
  text("+ - Increase Animation Speed", panelX + 10, panelY + panelHeight + 65);
  text("- - Decrease Animation Speed", panelX + 10, panelY + panelHeight + 85);
  text("R - Reset Array", panelX + 10, panelY + panelHeight + 105);
  text("Click buttons to interact", panelX + 10, panelY + panelHeight + 125);
}

void mousePressed() {
  if (resetHover) {
    resetArray();
  } else if (stopHover) {
    paused = !paused;
  } else if (decreaseSizeHover && n > 5) {
    n -= 2;
    resetArray();
  } else if (increaseSizeHover && n < 25) {
    n += 2;
    resetArray();
  } else if (decreaseSpeedHover && currentSpeed > 5) {
    currentSpeed -= 5;
    frameRate(currentSpeed);
  } else if (increaseSpeedHover) {
    currentSpeed += 5;
    frameRate(currentSpeed);
  }
}

void keyPressed() {
  if (key == 'p' || key == 'P') {
    paused = !paused;
  } else if (key == '+') {
    currentSpeed += 5;
    frameRate(currentSpeed);
  } else if (key == '-' && currentSpeed > 5) {
    currentSpeed -= 5;
    frameRate(currentSpeed);
  } else if (key == 'r' || key == 'R') {
    resetArray();
  }
}
