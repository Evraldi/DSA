int[] arr;
int n;
boolean sorted;
int i, j;
boolean paused = false;
int comparisons = 0;
int swaps = 0;
int steps = 0;
boolean swappedInThisStep = false;
float animationProgress = 0;
boolean isSwapping = false;
int currentSpeed = 10;

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
  decreaseSizeY = panelY + 220;
  increaseSizeX = panelX + 150;
  increaseSizeY = panelY + 220;

  // Animation Speed buttons - middle row
  decreaseSpeedX = panelX + 50;
  decreaseSpeedY = panelY + 280;
  increaseSpeedX = panelX + 150;
  increaseSpeedY = panelY + 280;

  // Reset and Pause buttons - bottom row
  resetX = panelX + 50;
  resetY = panelY + 340;
  stopX = panelX + 150;
  stopY = panelY + 340;

  resetArray();
}

void resetArray() {
  // Keep the current array size
  arr = new int[n];
  for (int k = 0; k < n; k++) {
    arr[k] = int(random(height * 0.7));
  }
  i = 0;
  j = 0;
  sorted = false;
  comparisons = 0;
  swaps = 0;
  steps = 0;
  swappedInThisStep = false;
  isSwapping = false;
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
    } else if (k < i) {
      fill(0, 150, 0); // Green for sorted portion
    } else if (isSwapping && (k == j || k == j + 1)) {
      fill(255, 165, 0); // Orange for swapping elements
    } else if (k == j || k == j + 1) {
      fill(255, 0, 0); // Red for elements being compared
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
    if (isSwapping) {
      // Handle animation of swapping
      animationProgress += 0.1;
      if (animationProgress >= 1) {
        // Complete the swap
        int temp = arr[j];
        arr[j] = arr[j + 1];
        arr[j + 1] = temp;
        isSwapping = false;
        swappedInThisStep = true;
        swaps++;
      }
    } else {
      if (j < n - i - 1) {
        comparisons++;
        if (arr[j] > arr[j + 1]) {
          // Start swapping animation
          isSwapping = true;
          animationProgress = 0;
        } else {
          j++;
        }
      } else {
        j = 0;
        i++;
        steps++;
        if (!swappedInThisStep || i >= n - 1) {
          sorted = true;
        }
        swappedInThisStep = false;
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
  text("Bubble Sort Visualizer", panelX + panelWidth/2, panelY + 15);

  // Draw algorithm information
  textSize(14);
  textAlign(LEFT, TOP);
  fill(0);
  String info = "Bubble Sort repeatedly steps through\nthe list, compares adjacent elements\nand swaps them if they are in the\nwrong order.";
  text(info, panelX + 15, panelY + 45);

  // Draw complexity information
  text("Time Complexity: O(n²)", panelX + 15, panelY + 110);
  text("Space Complexity: O(1)", panelX + 15, panelY + 130);

  // Draw current metrics
  textAlign(LEFT, TOP);
  text("Steps: " + steps, panelX + 15, panelY + 155);
  text("Comparisons: " + comparisons, panelX + 150, panelY + 155);
  text("Swaps: " + swaps, panelX + 15, panelY + 175);
  text("Speed: " + currentSpeed + " fps", panelX + 150, panelY + 175);



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
  } else if (isSwapping) {
    action = "Swapping elements " + arr[j] + " and " + arr[j+1];
    fill(255, 140, 0);
  } else {
    action = "Comparing elements " + j + " and " + (j+1);
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
