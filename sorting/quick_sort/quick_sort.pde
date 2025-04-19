int[] arr;
int n;
boolean sorted;
boolean paused = false;
int comparisons = 0;
int swaps = 0;
int steps = 0;
float animationProgress = 0;
boolean isAnimating = false;
int currentSpeed = 10;

// Quick sort specific variables
int pivotIndex = -1;
int leftPointer = -1;
int rightPointer = -1;
int currentPartitionStart = -1;
int currentPartitionEnd = -1;
boolean partitioning = false;
boolean swapping = false;
int swapIndex1 = -1;
int swapIndex2 = -1;
ArrayList<int[]> partitionStack = new ArrayList<int[]>();

// UI Panel dimensions
int panelWidth = 300;
int panelHeight = 400;
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

void setup() {
  size(1000, 700);
  panelX = width - panelWidth - 20;
  panelY = 20;

  // Initialize array size
  n = 30; // Default number of elements

  // Position all buttons with fixed pixel positions relative to panel
  // Array Size buttons - top row
  decreaseSizeX = panelX + 50;
  decreaseSizeY = panelY + 260;
  increaseSizeX = panelX + 150;
  increaseSizeY = panelY + 260;

  // Animation Speed buttons - middle row
  decreaseSpeedX = panelX + 50;
  decreaseSpeedY = panelY + 310;
  increaseSpeedX = panelX + 150;
  increaseSpeedY = panelY + 310;

  // Reset and Pause buttons - bottom row
  resetX = panelX + 50;
  resetY = panelY + 360;
  stopX = panelX + 150;
  stopY = panelY + 360;

  resetArray();
}

void resetArray() {
  // Keep the current array size
  arr = new int[n];
  for (int k = 0; k < n; k++) {
    arr[k] = int(random(height * 0.7));
  }

  // Reset quick sort variables
  pivotIndex = -1;
  leftPointer = -1;
  rightPointer = -1;
  currentPartitionStart = -1;
  currentPartitionEnd = -1;
  partitioning = false;
  swapping = false;
  swapIndex1 = -1;
  swapIndex2 = -1;
  partitionStack.clear();

  // Add initial partition (whole array)
  partitionStack.add(new int[] {0, n-1});

  // Reset counters
  sorted = false;
  comparisons = 0;
  swaps = 0;
  steps = 0;
  isAnimating = false;

  // Keep the current speed setting
  frameRate(currentSpeed);
}

void draw() {
  background(240);

  // Draw array bars
  drawArrayBars();

  // Update sorting algorithm
  updateSorting();

  // Draw information panel
  drawInfoPanel();

  // Draw buttons
  drawButtons();

  // Draw controls legend
  drawControlsLegend();
}

void drawArrayBars() {
  int barWidth = (width - panelWidth - 40) / n;

  for (int k = 0; k < n; k++) {
    // Determine the color based on the current state
    if (sorted) {
      fill(0, 200, 0); // All green when sorted
    } else if (k == pivotIndex) {
      fill(255, 0, 255); // Purple for pivot
    } else if (swapping && (k == swapIndex1 || k == swapIndex2)) {
      fill(255, 165, 0); // Orange for swapping elements
    } else if (k == leftPointer || k == rightPointer) {
      fill(255, 0, 0); // Red for pointers
    } else if (currentPartitionStart <= k && k <= currentPartitionEnd) {
      fill(100, 149, 237); // Light blue for current partition
    } else {
      fill(70, 130, 180); // Steel blue for unsorted elements
    }

    // Draw the bar
    rect(k * barWidth, height - arr[k] - 50, barWidth - 2, arr[k]);

    // Show array values
    fill(0);
    textSize(12);
    textAlign(CENTER, BOTTOM);
    text(arr[k], k * barWidth + barWidth / 2, height - arr[k] - 55);
  }
}

void updateSorting() {
  if (!paused && !sorted) {
    if (isAnimating) {
      // Handle animation
      animationProgress += 0.1;
      if (animationProgress >= 1) {
        isAnimating = false;

        if (swapping) {
          // Complete the swap
          int temp = arr[swapIndex1];
          arr[swapIndex1] = arr[swapIndex2];
          arr[swapIndex2] = temp;
          swapping = false;
          swaps++;
        }
      }
    } else {
      // If we're not currently partitioning, get the next partition from the stack
      if (!partitioning && !partitionStack.isEmpty()) {
        int[] partition = partitionStack.remove(0);
        currentPartitionStart = partition[0];
        currentPartitionEnd = partition[1];

        if (currentPartitionStart < currentPartitionEnd) {
          // Start partitioning this segment
          partitioning = true;
          pivotIndex = currentPartitionEnd; // Using last element as pivot
          leftPointer = currentPartitionStart;
          rightPointer = currentPartitionEnd - 1;
          steps++;
        }
      } else if (partitioning) {
        // Continue partitioning the current segment
        if (leftPointer <= rightPointer) {
          // Find element on left side to swap
          if (arr[leftPointer] <= arr[pivotIndex]) {
            leftPointer++;
            comparisons++;
          } else if (arr[rightPointer] > arr[pivotIndex]) {
            rightPointer--;
            comparisons++;
          } else {
            // Swap elements
            swapping = true;
            swapIndex1 = leftPointer;
            swapIndex2 = rightPointer;
            isAnimating = true;
            animationProgress = 0;
          }
        } else {
          // Swap pivot into its final position
          swapping = true;
          swapIndex1 = leftPointer;
          swapIndex2 = pivotIndex;
          isAnimating = true;
          animationProgress = 0;

          // After this swap, the pivot will be in its final position
          // Add the two resulting partitions to the stack
          if (currentPartitionStart < leftPointer - 1) {
            partitionStack.add(new int[] {currentPartitionStart, leftPointer - 1});
          }
          if (leftPointer + 1 < currentPartitionEnd) {
            partitionStack.add(new int[] {leftPointer + 1, currentPartitionEnd});
          }

          // Reset partitioning state
          partitioning = false;
        }
      } else {
        // No more partitions to process, sorting is complete
        sorted = true;
      }
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
  text("Quick Sort Visualizer", panelX + panelWidth/2, panelY + 15);

  // Draw algorithm information
  textSize(14);
  textAlign(LEFT, TOP);
  fill(0);
  String info = "Quick Sort is a divide-and-conquer\nalgorithm that picks an element as a\npivot and partitions the array around\nthe pivot. Elements smaller than the\npivot go to the left, larger to the right.";
  text(info, panelX + 15, panelY + 45);

  // Draw complexity information
  text("Time Complexity:", panelX + 15, panelY + 130);
  text("- Best/Average: O(n log n)", panelX + 15, panelY + 150);
  text("- Worst: O(n²)", panelX + 15, panelY + 170);
  text("Space Complexity: O(log n)", panelX + 15, panelY + 190);

  // Draw current metrics
  textAlign(LEFT, TOP);
  text("Steps: " + steps, panelX + 15, panelY + 215);
  text("Comparisons: " + comparisons, panelX + 150, panelY + 215);
  text("Swaps: " + swaps, panelX + 15, panelY + 235);
  text("Speed: " + currentSpeed + " fps", panelX + 150, panelY + 235);

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
  } else if (swapping) {
    action = "Swapping elements " + arr[swapIndex1] + " and " + arr[swapIndex2];
    fill(255, 140, 0);
  } else if (partitioning) {
    action = "Partitioning around pivot " + arr[pivotIndex];
    fill(0, 0, 150);
  } else {
    action = "Selecting next partition";
    fill(0, 0, 150);
  }
  text(action, width/2, height - 15);
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
  rect(20, 20, 220, 140, 5);

  fill(0);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Controls:", 30, 30);
  textSize(14);
  text("P - Pause/Resume", 30, 55);
  text("+ - Increase Animation Speed", 30, 75);
  text("- - Decrease Animation Speed", 30, 95);
  text("R - Reset Array", 30, 115);
  text("Click buttons to interact", 30, 135);
}

void mousePressed() {
  if (resetHover) {
    resetArray();
  } else if (stopHover) {
    paused = !paused;
  } else if (decreaseSizeHover && n > 10) {
    n -= 5;
    resetArray();
  } else if (increaseSizeHover && n < 100) {
    n += 5;
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
