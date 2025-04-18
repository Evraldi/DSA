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

// UI dimensions
int sidebarWidth = 250;
int buttonWidth = 100;
int buttonHeight = 40;
int buttonSpacing = 10;

// Button positions
int buttonX;
int pauseY, resetY, sizeDecY, sizeIncY, speedDecY, speedIncY;

// Button hover states
boolean pauseHover = false;
boolean resetHover = false;
boolean sizeDecHover = false;
boolean sizeIncHover = false;
boolean speedDecHover = false;
boolean speedIncHover = false;

// Current action being performed
String currentAction = "";

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
  // Use fullScreen() for maximum visualization space
  fullScreen();
  
  // Calculate button positions
  buttonX = width - sidebarWidth + (sidebarWidth - buttonWidth) / 2;
  pauseY = 180;
  resetY = pauseY + buttonHeight + buttonSpacing;
  sizeDecY = resetY + buttonHeight + buttonSpacing * 2;
  sizeIncY = sizeDecY + buttonHeight + buttonSpacing;
  speedDecY = sizeIncY + buttonHeight + buttonSpacing * 2;
  speedIncY = speedDecY + buttonHeight + buttonSpacing;
  
  // Initialize array size
  n = 32; // Default number of elements (power of 2 works best for merge sort)
  
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
  
  // Draw sidebar
  drawSidebar();
  
  // Draw matrix visualization
  drawMatrixVisualization();
  
  // Update sorting algorithm
  updateSorting();
  
  // Draw current action at the bottom
  drawCurrentAction();
}

void drawSidebar() {
  // Draw sidebar background
  fill(255);
  stroke(70, 130, 180);
  strokeWeight(2);
  rect(width - sidebarWidth, 0, sidebarWidth, height);
  
  // Draw title
  fill(25, 25, 112);
  textSize(24);
  textAlign(CENTER, TOP);
  text("Merge Sort Visualizer", width - sidebarWidth/2, 20);
  
  // Draw algorithm information
  textSize(14);
  textAlign(LEFT, TOP);
  fill(0);
  String info = "Merge Sort uses divide and conquer\nby recursively dividing the array\ninto halves, sorting them, and then\nmerging the sorted halves back\ntogether.";
  text(info, width - sidebarWidth + 20, 60);
  
  // Draw complexity information
  text("Time Complexity: O(n log n)", width - sidebarWidth + 20, 140);
  text("Space Complexity: O(n)", width - sidebarWidth + 20, 160);
  
  // Draw buttons
  drawButtons();
  
  // Draw current metrics
  fill(0);
  textAlign(LEFT, TOP);
  text("Array Size: " + n, width - sidebarWidth + 20, sizeDecY - 20);
  text("Animation Speed: " + currentSpeed + " fps", width - sidebarWidth + 20, speedDecY - 20);
  text("Steps: " + steps, width - sidebarWidth + 20, speedIncY + buttonHeight + 20);
  text("Comparisons: " + comparisons, width - sidebarWidth + 20, speedIncY + buttonHeight + 40);
  text("Merges: " + merges, width - sidebarWidth + 20, speedIncY + buttonHeight + 60);
  
  // Draw controls legend
  drawControlsLegend();
}

void drawButtons() {
  // Pause/Resume button
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth &&
      mouseY >= pauseY && mouseY <= pauseY + buttonHeight) {
    fill(100, 149, 237); // Hover color
    pauseHover = true;
  } else {
    fill(paused ? 220 : 70, paused ? 20 : 130, paused ? 60 : 180); // Red when paused, blue when running
    pauseHover = false;
  }
  rect(buttonX, pauseY, buttonWidth, buttonHeight, 5);
  fill(255);
  textAlign(CENTER, CENTER);
  text(paused ? "Resume" : "Pause", buttonX + buttonWidth/2, pauseY + buttonHeight/2);
  
  // Reset button
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth &&
      mouseY >= resetY && mouseY <= resetY + buttonHeight) {
    fill(100, 149, 237); // Hover color
    resetHover = true;
  } else {
    fill(70, 130, 180); // Normal color
    resetHover = false;
  }
  rect(buttonX, resetY, buttonWidth, buttonHeight, 5);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Reset", buttonX + buttonWidth/2, resetY + buttonHeight/2);
  
  // Decrease size button
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth &&
      mouseY >= sizeDecY && mouseY <= sizeDecY + buttonHeight) {
    fill(100, 149, 237); // Hover color
    sizeDecHover = true;
  } else {
    fill(70, 130, 180); // Normal color
    sizeDecHover = false;
  }
  rect(buttonX, sizeDecY, buttonWidth, buttonHeight, 5);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Size -", buttonX + buttonWidth/2, sizeDecY + buttonHeight/2);
  
  // Increase size button
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth &&
      mouseY >= sizeIncY && mouseY <= sizeIncY + buttonHeight) {
    fill(100, 149, 237); // Hover color
    sizeIncHover = true;
  } else {
    fill(70, 130, 180); // Normal color
    sizeIncHover = false;
  }
  rect(buttonX, sizeIncY, buttonWidth, buttonHeight, 5);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Size +", buttonX + buttonWidth/2, sizeIncY + buttonHeight/2);
  
  // Decrease speed button
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth &&
      mouseY >= speedDecY && mouseY <= speedDecY + buttonHeight) {
    fill(100, 149, 237); // Hover color
    speedDecHover = true;
  } else {
    fill(70, 130, 180); // Normal color
    speedDecHover = false;
  }
  rect(buttonX, speedDecY, buttonWidth, buttonHeight, 5);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Speed -", buttonX + buttonWidth/2, speedDecY + buttonHeight/2);
  
  // Increase speed button
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth &&
      mouseY >= speedIncY && mouseY <= speedIncY + buttonHeight) {
    fill(100, 149, 237); // Hover color
    speedIncHover = true;
  } else {
    fill(70, 130, 180); // Normal color
    speedIncHover = false;
  }
  rect(buttonX, speedIncY, buttonWidth, buttonHeight, 5);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Speed +", buttonX + buttonWidth/2, speedIncY + buttonHeight/2);
}

void drawControlsLegend() {
  // Draw controls legend at the bottom of the sidebar
  int legendY = height - 150;
  
  fill(0);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Keyboard Controls:", width - sidebarWidth + 20, legendY);
  textSize(14);
  text("P - Pause/Resume", width - sidebarWidth + 20, legendY + 25);
  text("+ - Increase Animation Speed", width - sidebarWidth + 20, legendY + 45);
  text("- - Decrease Animation Speed", width - sidebarWidth + 20, legendY + 65);
  text("R - Reset Array", width - sidebarWidth + 20, legendY + 85);
  text("Click buttons to interact", width - sidebarWidth + 20, legendY + 105);
}

void drawMatrixVisualization() {
  // Calculate dimensions for the visualization area
  float visualWidth = width - sidebarWidth - 40;
  float visualHeight = height - 150;
  float x = 20;
  float y = 50;
  
  // Draw the original array at the top
  fill(0);
  textAlign(LEFT, BOTTOM);
  textSize(16);
  text("Original Array:", x, y - 5);
  
  float cellWidth = visualWidth / n;
  float cellHeight = 40;
  
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

void drawCurrentAction() {
  // Draw current action at the bottom of the screen
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
  text(action, (width - sidebarWidth) / 2, height - 15);
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

void mousePressed() {
  if (pauseHover) {
    paused = !paused;
  } else if (resetHover) {
    resetArray();
  } else if (sizeDecHover && n > 8) {
    // For merge sort, we'll keep array sizes as powers of 2
    n = n / 2;
    resetArray();
  } else if (sizeIncHover && n < 64) {
    n = n * 2;
    resetArray();
  } else if (speedDecHover && currentSpeed > 5) {
    currentSpeed -= 5;
    frameRate(currentSpeed);
  } else if (speedIncHover) {
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
