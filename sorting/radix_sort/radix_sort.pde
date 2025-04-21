// Radix Sort Visualization
// This visualizer demonstrates the radix sort algorithm, which sorts numbers by processing individual digits

int[] arr;
int n = 15; // Default array size
boolean sorted = false;
boolean paused = false;
int comparisons = 0;
int steps = 0;
float animationProgress = 0;
boolean isAnimating = false;
int currentSpeed = 10;

// Radix sort specific variables
int currentDigit = 0; // Current digit being processed (0 = ones, 1 = tens, 2 = hundreds, etc.)
int maxDigits = 0; // Maximum number of digits in any number in the array
int[] countArray = new int[10]; // Count array for counting sort (0-9 digits)
int[][] buckets = new int[10][]; // Buckets for visualization
int[] bucketSizes = new int[10]; // Size of each bucket
boolean distributingPhase = true; // True when distributing to buckets, false when collecting
int currentElement = 0; // Current element being processed
int maxValue = 0; // Maximum value in the array

// UI Panel dimensions
int panelWidth = 300;
int panelHeight = 550; // Significantly increased panel height for better button spacing
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
int bucketsViewX, bucketsViewY;
int bucketsViewWidth, bucketsViewHeight;

void setup() {
  // Use fullScreen() instead of size() to open in full screen mode
  fullScreen();
  panelX = width - panelWidth - 20;
  panelY = 20;

  // Position all buttons with fixed pixel positions relative to panel
  // Calculate button positions with proper spacing
  int labelHeight = 30; // Height for labels above buttons

  // Array Size buttons - top row
  decreaseSizeX = panelX + 50;
  decreaseSizeY = panelY + 320; // Much more space from top
  increaseSizeX = panelX + 170; // Increased spacing between buttons
  increaseSizeY = panelY + 320;

  // Animation Speed buttons - middle row
  decreaseSpeedX = panelX + 50;
  decreaseSpeedY = panelY + 410; // Much more vertical spacing between rows (90px)
  increaseSpeedX = panelX + 170; // Increased spacing between buttons
  increaseSpeedY = panelY + 410;

  // Reset and Pause buttons - bottom row
  resetX = panelX + 50;
  resetY = panelY + 500; // Much more vertical spacing between rows (90px)
  stopX = panelX + 170; // Increased spacing between buttons
  stopY = panelY + 500;

  // Set up visualization areas with more space
  arrayViewX = 20;
  arrayViewY = 20;
  arrayViewWidth = width - panelWidth - 60;
  arrayViewHeight = 250; // Increased height for array view

  bucketsViewX = 20;
  bucketsViewY = arrayViewY + arrayViewHeight + 60; // More space between views
  bucketsViewWidth = width - panelWidth - 60;
  bucketsViewHeight = 350; // Increased height for buckets view

  resetArray();
}

void resetArray() {
  // Keep the current array size
  arr = new int[n];
  for (int k = 0; k < n; k++) {
    arr[k] = int(random(10, 999)); // Values between 10 and 999 for better visualization
  }

  // Find maximum value to determine max digits
  maxValue = 0;
  for (int i = 0; i < n; i++) {
    if (arr[i] > maxValue) {
      maxValue = arr[i];
    }
  }

  // Calculate max digits
  maxDigits = 1;
  int temp = maxValue;
  while (temp >= 10) {
    maxDigits++;
    temp /= 10;
  }

  // Initialize buckets
  for (int i = 0; i < 10; i++) {
    buckets[i] = new int[n]; // Maximum possible size
    bucketSizes[i] = 0;
  }

  // Reset radix sort variables
  currentDigit = 0;
  distributingPhase = true;
  currentElement = 0;

  // Reset counters
  sorted = false;
  comparisons = 0;
  steps = 0;
  isAnimating = false;

  // Keep the current speed setting
  frameRate(currentSpeed);
}

void draw() {
  background(240);

  // Draw array view
  drawArrayView();

  // Draw buckets view
  drawBucketsView();

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
  text("Array", arrayViewX + 10, arrayViewY + 10);

  // Calculate bar dimensions
  int barWidth = min(arrayViewWidth / n, 80); // Limit maximum bar width
  int maxBarHeight = arrayViewHeight - 80; // More space for labels

  // Calculate the starting x position to center the bars
  int startX = arrayViewX + (arrayViewWidth - (barWidth * n)) / 2;

  // Draw array bars
  for (int k = 0; k < n; k++) {
    // Calculate bar height proportional to value
    int barHeight = int(map(arr[k], 0, maxValue, 30, maxBarHeight)); // Minimum bar height

    // Determine the color based on the current state
    if (sorted) {
      fill(0, 200, 0); // Green for sorted array
    } else if (isAnimating && k == currentElement) {
      fill(255, 165, 0); // Orange for current element
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

    // Highlight the current digit being processed
    if (!sorted && currentDigit < maxDigits) {
      int digitValue = getDigit(arr[k], currentDigit);
      fill(255, 0, 0);
      textSize(min(16, barWidth - 4)); // Larger text for digit
      textAlign(CENTER, CENTER);
      text(digitValue, x + barWidth / 2, y + barHeight / 2);
    }
  }
}

void drawBucketsView() {
  // Draw buckets view background
  fill(255, 255, 255, 50);
  stroke(70, 130, 180);
  strokeWeight(1);
  rect(bucketsViewX, bucketsViewY, bucketsViewWidth, bucketsViewHeight, 5);

  // Draw buckets title
  fill(25, 25, 112);
  textSize(18); // Larger title text
  textAlign(LEFT, TOP);
  // Convert digit position to human-readable format (1 = ones, 2 = tens, etc.)
  String digitName;
  if (currentDigit == 0) digitName = "ones";
  else if (currentDigit == 1) digitName = "tens";
  else if (currentDigit == 2) digitName = "hundreds";
  else digitName = "position " + (currentDigit + 1);
  text("Digit Buckets (Current: " + digitName + " place)", bucketsViewX + 10, bucketsViewY + 10);

  // Split buckets into two rows (0-4 and 5-9)
  int bucketsPerRow = 5;
  int bucketWidth = bucketsViewWidth / bucketsPerRow; // Wider buckets
  int bucketHeight = (bucketsViewHeight - 80) / 2; // Split height for two rows
  int rowSpacing = 40; // Space between rows

  // Draw the buckets in two rows
  for (int i = 0; i < 10; i++) {
    // Calculate row and position within row
    int row = i / bucketsPerRow; // 0 for first row (0-4), 1 for second row (5-9)
    int col = i % bucketsPerRow; // Position within row (0-4)

    // Calculate bucket position
    int bucketX = bucketsViewX + col * bucketWidth;
    int bucketY = bucketsViewY + 40 + row * (bucketHeight + rowSpacing);

    // Draw bucket label
    fill(0);
    textSize(16); // Larger bucket labels
    textAlign(CENTER, TOP);
    text("Bucket " + i, bucketX + bucketWidth / 2, bucketY - 25);

    // Draw bucket outline
    stroke(70, 130, 180);
    strokeWeight(1);
    fill(255, 255, 255, 30);
    rect(bucketX + 5, bucketY, bucketWidth - 10, bucketHeight, 5);

    // Draw elements in the bucket
    int elementHeight = min(40, (bucketHeight - 20) / max(bucketSizes[i], 5)); // Ensure minimum spacing
    for (int j = 0; j < bucketSizes[i]; j++) {
      // Determine color based on the current element
      if (distributingPhase && currentElement < n && buckets[i][j] == arr[currentElement]) {
        fill(255, 165, 0); // Orange for current element being distributed
      } else {
        fill(100, 149, 237); // Blue for normal elements
      }

      // Draw element rectangle
      rect(bucketX + 10,
           bucketY + 10 + j * elementHeight,
           bucketWidth - 20,
           elementHeight - 2);

      // Show value
      fill(0);
      textSize(min(16, elementHeight - 4)); // Larger text for values
      textAlign(CENTER, CENTER);
      text(buckets[i][j],
           bucketX + bucketWidth / 2,
           bucketY + 10 + j * elementHeight + elementHeight / 2);
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

        if (distributingPhase) {
          // Add current element to appropriate bucket
          int digit = getDigit(arr[currentElement], currentDigit);
          buckets[digit][bucketSizes[digit]] = arr[currentElement];
          bucketSizes[digit]++;

          // Move to next element
          currentElement++;

          // If all elements distributed, switch to collecting phase
          if (currentElement >= n) {
            distributingPhase = false;
            currentElement = 0;
          }
        } else {
          // Collecting phase - gather elements from buckets back to array
          int arrIndex = 0;

          // Collect elements from all buckets
          for (int i = 0; i < 10; i++) {
            for (int j = 0; j < bucketSizes[i]; j++) {
              arr[arrIndex++] = buckets[i][j];
            }
            bucketSizes[i] = 0; // Clear bucket
          }

          // Move to next digit
          currentDigit++;
          steps++;

          // If all digits processed, sorting is complete
          if (currentDigit >= maxDigits) {
            sorted = true;
          } else {
            // Reset for next digit
            distributingPhase = true;
            currentElement = 0;
          }
        }

        // Start next animation
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

// Helper function to get a specific digit from a number
int getDigit(int number, int position) {
  // position 0 = ones, 1 = tens, 2 = hundreds, etc.
  return (number / int(pow(10, position))) % 10;
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
  text("Radix Sort Visualizer", panelX + panelWidth/2, panelY + 15);

  // Draw algorithm information
  textSize(14);
  textAlign(LEFT, TOP);
  fill(0);
  String info = "Radix Sort is a non-comparative\nsorting algorithm that sorts numbers\ndigit by digit. It processes each\ndigit position from least significant\nto most significant, using a stable\nsorting algorithm (counting sort)\nfor each digit position.";
  text(info, panelX + 15, panelY + 45);

  // Draw complexity information with more spacing
  text("Time Complexity: O(d * n)", panelX + 15, panelY + 160); // Increased y-position
  text("Space Complexity: O(n + k)", panelX + 15, panelY + 185); // Increased y-position
  text("where d = # of digits, n = array size", panelX + 15, panelY + 210); // Increased y-position
  text("and k = range of digits (10)", panelX + 15, panelY + 230); // Increased y-position

  // Draw current metrics
  textAlign(LEFT, TOP);
  text("Steps: " + steps, panelX + 15, panelY + 255); // Increased y-position
  // Convert digit position to human-readable format
  String currentDigitName;
  if (currentDigit == 0) currentDigitName = "ones";
  else if (currentDigit == 1) currentDigitName = "tens";
  else if (currentDigit == 2) currentDigitName = "hundreds";
  else currentDigitName = "position " + (currentDigit + 1);
  text("Current Digit: " + currentDigitName, panelX + 150, panelY + 255); // Increased y-position
  text("Max Digits: " + maxDigits, panelX + 15, panelY + 275); // Increased y-position
  text("Speed: " + currentSpeed + " fps", panelX + 150, panelY + 275); // Increased y-position

  // Draw current phase
  String phase = distributingPhase ? "Distributing to Buckets" : "Collecting from Buckets";
  text("Current Phase: " + phase, panelX + 15, panelY + 295); // Increased y-position

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
  } else if (distributingPhase) {
    // Convert digit position to human-readable format
    String digitName;
    if (currentDigit == 0) digitName = "ones";
    else if (currentDigit == 1) digitName = "tens";
    else if (currentDigit == 2) digitName = "hundreds";
    else digitName = "position " + (currentDigit + 1);
    action = "Distributing elements by " + digitName + " place";
    fill(0, 0, 150);
  } else {
    action = "Collecting elements from buckets";
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
    String explanation = distributingPhase ?
      "Distributing elements by " + (currentDigit == 0 ? "ones" : currentDigit == 1 ? "tens" : currentDigit == 2 ? "hundreds" : "position " + (currentDigit + 1)) + " place" :
      "Collecting elements from buckets for next digit";
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
  text("Array Size", panelX + panelWidth/2, decreaseSizeY - 15);

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
  text("Animation Speed", panelX + panelWidth/2, decreaseSpeedY - 15);

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
