int[] arr;
int n;
boolean sorted;
boolean paused = false;
int comparisons = 0;
int merges = 0;
int steps = 0;
float animationProgress = 0;
boolean isAnimating = false;
int currentSpeed = 10;

// Merge sort visualization variables
int[] auxArray; // Auxiliary array for merging
int leftStart, rightStart, rightEnd; // Current merge boundaries
int currentIndex; // Current index being processed
int mergeIndex; // Current index in the merge process

// Matrix visualization variables
ArrayList<MergeStep> mergeSteps; // List of all merge steps
int currentStepIndex = 0; // Current step being visualized

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

// Merge sort state
String currentAction = ""; // Current action being performed

// Class to represent a merge step in the visualization
class MergeStep {
  int start, mid, end; // Boundaries of this merge step
  int level; // Level in the merge sort tree (0 = whole array, 1 = halves, etc.)
  boolean isSplit; // Whether this is a split step or a merge step
  boolean isActive; // Whether this step is currently active
  boolean isCompleted; // Whether this step has been completed
  int[] values; // Values in this subarray

  MergeStep(int start, int mid, int end, int level, boolean isSplit) {
    this.start = start;
    this.mid = mid;
    this.end = end;
    this.level = level;
    this.isSplit = isSplit;
    this.isActive = false;
    this.isCompleted = false;

    // Copy values from the main array
    this.values = new int[end - start + 1];
    for (int i = 0; i < values.length; i++) {
      this.values[i] = arr[start + i];
    }
  }

  // Draw this merge step
  void draw(float x, float y, float w, float h) {
    // Determine color based on state
    if (isCompleted) {
      fill(0, 150, 0, 100); // Green for completed steps
    } else if (isActive) {
      fill(255, 165, 0, 100); // Orange for active steps
    } else {
      fill(70, 130, 180, 100); // Blue for pending steps
    }

    // Draw background
    stroke(0);
    rect(x, y, w, h, 5);

    // Draw divider line for split steps
    if (isSplit) {
      stroke(255, 0, 0);
      float midX = x + (mid - start + 0.5) * (w / (end - start + 1));
      line(midX, y, midX, y + h);
    }

    // Draw values as text
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(14);

    float cellWidth = w / values.length;
    for (int i = 0; i < values.length; i++) {
      // Draw cell background
      if (isActive && !isSplit && i == currentIndex - start) {
        fill(255, 0, 0, 100); // Highlight current index
      } else if (isCompleted) {
        fill(0, 200, 0, 50); // Green for completed values
      } else {
        fill(255, 255, 255, 50); // White for normal values
      }
      rect(x + i * cellWidth, y, cellWidth, h);

      // Draw value
      fill(0);
      text(values[i], x + i * cellWidth + cellWidth/2, y + h/2);
    }

    // Draw label
    fill(0);
    textAlign(CENTER, BOTTOM);
    textSize(12);
    if (isSplit) {
      text("Split [" + start + "..." + end + "]", x + w/2, y - 5);
    } else {
      text("Merge [" + start + "..." + mid + "] and [" + (mid+1) + "..." + end + "]", x + w/2, y - 5);
    }
  }

  // Update values after merging
  void updateValues() {
    for (int i = 0; i < values.length; i++) {
      this.values[i] = arr[start + i];
    }
    this.isCompleted = true;
    this.isActive = false;
  }
}

void setup() {
  // Use fullScreen() instead of size() to maximize the visualization
  fullScreen();
  panelX = width - panelWidth - 20;
  panelY = 20;

  // Initialize array size - larger default for fullscreen mode
  n = 16; // Default number of elements (power of 2 works best for merge sort)

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
  auxArray = new int[n];
  for (int k = 0; k < n; k++) {
    arr[k] = int(random(100)) + 1; // Values between 1 and 100 for better visibility
    auxArray[k] = arr[k]; // Initialize auxiliary array
  }

  // Initialize merge sort variables
  leftStart = 0;
  rightEnd = n - 1;
  rightStart = (leftStart + rightEnd) / 2 + 1;
  currentIndex = leftStart;
  mergeIndex = 0;

  // Generate all merge steps
  mergeSteps = new ArrayList<MergeStep>();
  generateMergeSteps(0, n-1, 0);
  currentStepIndex = 0;

  sorted = false;
  comparisons = 0;
  merges = 0;
  steps = 0;
  isAnimating = false;
  currentAction = "Starting merge sort";

  // Keep the current speed setting
  frameRate(currentSpeed);
}

// Recursively generate all merge steps
void generateMergeSteps(int start, int end, int level) {
  if (start < end) {
    int mid = (start + end) / 2;

    // Add split step
    mergeSteps.add(new MergeStep(start, mid, end, level, true));

    // Recursively generate steps for left and right halves
    generateMergeSteps(start, mid, level + 1);
    generateMergeSteps(mid + 1, end, level + 1);

    // Add merge step
    mergeSteps.add(new MergeStep(start, mid, end, level, false));
  }
}

void draw() {
  background(240);

  // Draw matrix visualization
  drawMatrixVisualization();

  // Update sorting algorithm
  updateSorting();

  // Draw information panel
  drawInfoPanel();

  // Draw buttons
  drawButtons();

  // Draw controls legend
  drawControlsLegend();
}

void drawMatrixVisualization() {
  // Calculate dimensions for the visualization area
  float visualWidth = width - panelWidth - 40;
  float visualHeight = height - 150;
  float x = 20;
  float y = 150; // Start visualization lower to avoid overlap with controls

  // Draw the original array at the top
  fill(0);
  textAlign(LEFT, BOTTOM);
  textSize(16);
  text("Original Array:", x, y - 5);

  float cellWidth = visualWidth / n;
  float cellHeight = 40;

  // Move the original array down a bit to avoid overlap with controls
  y = 80;

  for (int i = 0; i < n; i++) {
    // Draw cell background
    fill(200, 200, 200, 100);
    rect(x + i * cellWidth, y, cellWidth, cellHeight);

    // Draw value
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(14);
    text(arr[i], x + i * cellWidth + cellWidth/2, y + cellHeight/2);
  }

  // Draw merge steps
  int maxLevel = int(log(n) / log(2));
  float stepHeight = (visualHeight - cellHeight - 20) / (maxLevel * 2 + 1);

  // Adjust starting y position for merge steps to be below the original array
  float startY = y + cellHeight + 30;

  for (int i = 0; i < mergeSteps.size(); i++) {
    MergeStep step = mergeSteps.get(i);
    float stepY = startY + step.level * stepHeight * 2 + (step.isSplit ? 0 : stepHeight);
    float stepWidth = cellWidth * (step.end - step.start + 1);
    float stepX = x + step.start * cellWidth;

    // Only draw steps that are active or completed
    if (i <= currentStepIndex || step.isCompleted) {
      step.draw(stepX, stepY, stepWidth, stepHeight * 0.8);
    }
  }

  // Draw the final sorted array at the bottom
  if (sorted) {
    fill(0);
    textAlign(LEFT, BOTTOM);
    textSize(16);
    text("Sorted Array:", x, height - 60);

    for (int i = 0; i < n; i++) {
      // Draw cell background
      fill(0, 200, 0, 100);
      rect(x + i * cellWidth, height - 60 + 5, cellWidth, cellHeight);

      // Draw value
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(14);
      text(arr[i], x + i * cellWidth + cellWidth/2, height - 60 + 5 + cellHeight/2);
    }
  }
}

void updateSorting() {
  if (!paused && !sorted) {
    if (isAnimating) {
      // Animation for current step
      animationProgress += 0.05;
      if (animationProgress >= 1) {
        // Complete the current step
        isAnimating = false;

        MergeStep currentStep = mergeSteps.get(currentStepIndex);

        if (!currentStep.isSplit) {
          // This is a merge step, perform the actual merge
          mergeSubarrays(currentStep.start, currentStep.mid, currentStep.end);
          currentStep.updateValues();
          merges++;
        }

        // Move to next step
        currentStepIndex++;
        steps++;

        // Check if we've completed all steps
        if (currentStepIndex >= mergeSteps.size()) {
          sorted = true;
          currentAction = "Sorting complete!";
          return;
        }

        // Activate the next step
        MergeStep nextStep = mergeSteps.get(currentStepIndex);
        nextStep.isActive = true;

        if (nextStep.isSplit) {
          currentAction = "Splitting [" + nextStep.start + "..." + nextStep.end + "]";
        } else {
          currentAction = "Merging [" + nextStep.start + "..." + nextStep.mid + "] and [" + (nextStep.mid+1) + "..." + nextStep.end + "]";
        }
      }
    } else {
      // Start animation for current step
      isAnimating = true;
      animationProgress = 0;

      // Activate the first step if we're just starting
      if (currentStepIndex == 0) {
        MergeStep firstStep = mergeSteps.get(0);
        firstStep.isActive = true;
        currentAction = "Splitting [" + firstStep.start + "..." + firstStep.end + "]";
      }
    }
  }
}

// Perform the actual merge of two subarrays
void mergeSubarrays(int start, int mid, int end) {
  int[] temp = new int[end - start + 1];
  int i = start, j = mid + 1, k = 0;

  // Merge the two subarrays
  while (i <= mid && j <= end) {
    comparisons++;
    if (arr[i] <= arr[j]) {
      temp[k++] = arr[i++];
    } else {
      temp[k++] = arr[j++];
    }
  }

  // Copy remaining elements
  while (i <= mid) {
    temp[k++] = arr[i++];
  }

  while (j <= end) {
    temp[k++] = arr[j++];
  }

  // Copy back to original array
  for (i = 0; i < temp.length; i++) {
    arr[start + i] = temp[i];
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
  text("Merge Sort Visualizer", panelX + panelWidth/2, panelY + 15);

  // Draw algorithm information
  textSize(14);
  textAlign(LEFT, TOP);
  fill(0);
  String info = "Merge Sort uses divide and conquer\nby recursively dividing the array\ninto halves, sorting them, and then\nmerging the sorted halves back\ntogether.";
  text(info, panelX + 15, panelY + 45);

  // Draw complexity information
  text("Time Complexity: O(n log n)", panelX + 15, panelY + 130);
  text("Space Complexity: O(n)", panelX + 15, panelY + 150);

  // Draw current metrics
  textAlign(LEFT, TOP);
  text("Steps: " + steps, panelX + 15, panelY + 175);
  text("Comparisons: " + comparisons, panelX + 150, panelY + 175);
  text("Merges: " + merges, panelX + 15, panelY + 195);
  text("Speed: " + currentSpeed + " fps", panelX + 150, panelY + 195);

  // Draw current action
  textAlign(CENTER, BOTTOM);
  fill(0);
  String action = currentAction;
  if (sorted) {
    action = "Array Sorted!";
    fill(0, 150, 0);
  } else if (paused) {
    action = "Paused";
    fill(150, 0, 0);
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
  // Move the controls legend to the top right corner, next to the panel
  fill(255);
  stroke(70, 130, 180);
  strokeWeight(1);
  rect(panelX - 240, panelY, 220, 140, 5);

  fill(0);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Controls:", panelX - 230, panelY + 10);
  textSize(14);
  text("P - Pause/Resume", panelX - 230, panelY + 35);
  text("+ - Increase Animation Speed", panelX - 230, panelY + 55);
  text("- - Decrease Animation Speed", panelX - 230, panelY + 75);
  text("R - Reset Array", panelX - 230, panelY + 95);
  text("Click buttons to interact", panelX - 230, panelY + 115);
}

void mousePressed() {
  if (resetHover) {
    resetArray();
  } else if (stopHover) {
    paused = !paused;
  } else if (decreaseSizeHover && n > 8) {
    // For merge sort, we'll keep array sizes as powers of 2
    n = n / 2;
    resetArray();
  } else if (increaseSizeHover && n < 64) {
    n = n * 2;
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
