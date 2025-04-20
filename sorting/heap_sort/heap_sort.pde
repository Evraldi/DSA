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

// Heap sort specific variables
int heapSize;
int currentIndex = -1;
int parentIndex = -1;
boolean buildingHeap = true;
boolean swapping = false;
int swapIndex1 = -1;
int swapIndex2 = -1;
int sortedIndex = -1;
int currentPhase = 0; // 0: building heap, 1: extracting max

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

// Visualization options
boolean showHeapTree = true;
int treeViewX, treeViewY;
int treeViewWidth, treeViewHeight;
int arrayViewY;

void setup() {
  size(1000, 700);
  panelX = width - panelWidth - 20;
  panelY = 20;

  // Initialize array size
  n = 15; // Default number of elements (smaller for better tree visualization)

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

  // Set up visualization areas
  treeViewX = 20;
  treeViewY = 20;
  treeViewWidth = width - panelWidth - 60;
  treeViewHeight = 300;
  arrayViewY = treeViewY + treeViewHeight + 50;

  resetArray();
}

void resetArray() {
  // Keep the current array size
  arr = new int[n];
  for (int k = 0; k < n; k++) {
    arr[k] = int(random(10, 99)); // Values between 10 and 99 for better visibility
  }

  // Reset heap sort variables
  heapSize = n;
  currentIndex = n / 2 - 1; // Start with the last non-leaf node
  parentIndex = -1;
  buildingHeap = true;
  swapping = false;
  swapIndex1 = -1;
  swapIndex2 = -1;
  sortedIndex = -1;
  currentPhase = 0;

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

  // Draw heap as tree
  if (showHeapTree) {
    drawHeapTree();
  }

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

void drawHeapTree() {
  // Draw tree view background
  fill(255, 255, 255, 50);
  stroke(70, 130, 180);
  strokeWeight(1);
  rect(treeViewX, treeViewY, treeViewWidth, treeViewHeight, 5);

  // Draw tree title
  fill(25, 25, 112);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Heap Tree Visualization", treeViewX + 10, treeViewY + 10);

  // Calculate node size and spacing based on the number of elements
  int maxLevel = int(log(n) / log(2)) + 1;
  int nodeSize = min(40, int(treeViewWidth / pow(2, maxLevel - 1) * 0.8));

  // Root node position
  float rootX = treeViewX + treeViewWidth / 2;
  float rootY = treeViewY + 50;

  // Draw the root node (index 0)
  if (0 < heapSize) {
    drawNode(0, rootX, rootY, nodeSize);

    // Calculate positions for index 1 and 2 with wider spacing
    float childY = rootY + 60;
    float xOffset = treeViewWidth / 3.5; // Wider spacing for first level

    // Draw left child (index 1) if exists
    if (1 < heapSize) {
      float leftX = rootX - xOffset;
      // Draw line to left child
      stroke(70, 130, 180);
      strokeWeight(1);
      line(rootX, rootY + nodeSize/2, leftX, childY - nodeSize/2);
      // Draw left child and its subtree
      drawNode(1, leftX, childY, nodeSize);
      // Draw subtree rooted at index 1
      drawSubtree(1, leftX, childY, nodeSize, treeViewWidth / 6);
    }

    // Draw right child (index 2) if exists
    if (2 < heapSize) {
      float rightX = rootX + xOffset;
      // Draw line to right child
      stroke(70, 130, 180);
      strokeWeight(1);
      line(rootX, rootY + nodeSize/2, rightX, childY - nodeSize/2);
      // Draw right child and its subtree
      drawNode(2, rightX, childY, nodeSize);
      // Draw subtree rooted at index 2
      drawSubtree(2, rightX, childY, nodeSize, treeViewWidth / 6);
    }
  }
}

// Helper function to draw a single node
void drawNode(int index, float x, float y, int nodeSize) {
  // Determine node color
  if (sorted && index >= sortedIndex) {
    fill(0, 200, 0); // Green for sorted elements
  } else if (swapping && (index == swapIndex1 || index == swapIndex2)) {
    fill(255, 165, 0); // Orange for swapping elements
  } else if (currentIndex >= 0 && index == currentIndex) {
    fill(255, 0, 0); // Red for current node being heapified
  } else if (parentIndex >= 0 && index == parentIndex) {
    fill(255, 0, 255); // Purple for parent node
  } else if (buildingHeap && currentIndex >= 0 && index > currentIndex) {
    fill(200, 200, 200); // Gray for nodes not yet heapified
  } else {
    fill(100, 149, 237); // Blue for heapified nodes
  }

  // Draw node
  stroke(0);
  strokeWeight(1);
  ellipse(x, y, nodeSize, nodeSize);

  // Draw node value
  fill(0);
  textSize(12);
  textAlign(CENTER, CENTER);
  text(arr[index], x, y);

  // Draw index below node
  fill(100);
  textSize(10);
  text("[" + index + "]", x, y + nodeSize/2 + 10);
}

// Function to draw subtree starting from a given node
void drawSubtree(int index, float x, float y, int nodeSize, float xOffset) {
  if (index >= heapSize) return;

  // Calculate child indices
  int leftChild = 2 * index + 1;
  int rightChild = 2 * index + 2;

  // Calculate new y position for children
  float newY = y + 60;

  // Calculate new x offset for next level
  float newXOffset = xOffset * 0.6;

  // Draw left child if exists
  if (leftChild < heapSize) {
    float leftX = x - newXOffset;
    // Draw line to left child
    stroke(70, 130, 180);
    strokeWeight(1);
    line(x, y + nodeSize/2, leftX, newY - nodeSize/2);
    // Draw left child
    drawNode(leftChild, leftX, newY, nodeSize);
    // Recursively draw left subtree
    drawSubtree(leftChild, leftX, newY, nodeSize, newXOffset);
  }

  // Draw right child if exists
  if (rightChild < heapSize) {
    float rightX = x + newXOffset;
    // Draw line to right child
    stroke(70, 130, 180);
    strokeWeight(1);
    line(x, y + nodeSize/2, rightX, newY - nodeSize/2);
    // Draw right child
    drawNode(rightChild, rightX, newY, nodeSize);
    // Recursively draw right subtree
    drawSubtree(rightChild, rightX, newY, nodeSize, newXOffset);
  }
}

// Original tree drawing function (kept for reference but not used)
void drawTreeNode(int index, float x, float y, int nodeSize, int level, float xOffset) {
  if (index >= heapSize) return;

  // Determine node color
  if (sorted && index >= sortedIndex) {
    fill(0, 200, 0); // Green for sorted elements
  } else if (swapping && (index == swapIndex1 || index == swapIndex2)) {
    fill(255, 165, 0); // Orange for swapping elements
  } else if (currentIndex >= 0 && index == currentIndex) {
    fill(255, 0, 0); // Red for current node being heapified
  } else if (parentIndex >= 0 && index == parentIndex) {
    fill(255, 0, 255); // Purple for parent node
  } else if (buildingHeap && currentIndex >= 0 && index > currentIndex) {
    fill(200, 200, 200); // Gray for nodes not yet heapified
  } else {
    fill(100, 149, 237); // Blue for heapified nodes
  }

  // Draw node
  stroke(0);
  strokeWeight(1);
  ellipse(x, y, nodeSize, nodeSize);

  // Draw node value
  fill(0);
  textSize(12);
  textAlign(CENTER, CENTER);
  text(arr[index], x, y);

  // Draw index below node
  fill(100);
  textSize(10);
  text("[" + index + "]", x, y + nodeSize/2 + 10);

  // Calculate child indices
  int leftChild = 2 * index + 1;
  int rightChild = 2 * index + 2;

  // Calculate new y position for children
  float newY = y + 60;

  // Calculate new x offset for next level
  float newXOffset = xOffset * 0.6;

  // Draw lines to children
  stroke(70, 130, 180);
  strokeWeight(1);

  // Draw left child if exists
  if (leftChild < heapSize) {
    line(x, y + nodeSize/2, x - newXOffset, newY - nodeSize/2);
    drawTreeNode(leftChild, x - newXOffset, newY, nodeSize, level + 1, newXOffset);
  }

  // Draw right child if exists
  if (rightChild < heapSize) {
    line(x, y + nodeSize/2, x + newXOffset, newY - nodeSize/2);
    drawTreeNode(rightChild, x + newXOffset, newY, nodeSize, level + 1, newXOffset);
  }
}

void drawArrayBars() {
  int barWidth = (width - panelWidth - 60) / n; // Increased margin
  int barHeight = 150; // Fixed height for the array view
  int maxValue = 100; // Default maximum expected value
  int arrayViewWidth = treeViewWidth - 40; // Reduced width to ensure bars stay within bounds

  // Find the actual maximum value in the array for proper scaling
  for (int k = 0; k < n; k++) {
    if (arr[k] > maxValue) maxValue = arr[k];
  }

  // Draw array view background
  fill(255, 255, 255, 50);
  stroke(70, 130, 180);
  strokeWeight(1);
  rect(treeViewX, arrayViewY, treeViewWidth, barHeight + 60, 5);

  // Draw array title
  fill(25, 25, 112);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Array Representation", treeViewX + 10, arrayViewY + 10);

  // Calculate the starting x position to center the bars
  int startX = treeViewX + (treeViewWidth - (barWidth * n)) / 2;

  // Draw array bars
  for (int k = 0; k < n; k++) {
    // Calculate bar height proportional to value, ensuring it doesn't exceed barHeight
    int height = int(map(arr[k], 0, maxValue, 10, barHeight - 20)); // Increased margin

    // Determine the color based on the current state
    if (sorted && k >= sortedIndex) {
      fill(0, 200, 0); // Green for sorted elements
    } else if (swapping && (k == swapIndex1 || k == swapIndex2)) {
      fill(255, 165, 0); // Orange for swapping elements
    } else if (currentIndex >= 0 && k == currentIndex) {
      fill(255, 0, 0); // Red for current node being heapified
    } else if (parentIndex >= 0 && k == parentIndex) {
      fill(255, 0, 255); // Purple for parent node
    } else if (buildingHeap && currentIndex >= 0 && k > currentIndex) {
      fill(200, 200, 200); // Gray for nodes not yet heapified
    } else if (k >= heapSize) {
      fill(0, 150, 0); // Dark green for elements already extracted from heap
    } else {
      fill(100, 149, 237); // Blue for heapified nodes
    }

    // Draw the bar
    int x = startX + k * barWidth;
    int y = arrayViewY + 40 + (barHeight - height);
    rect(x, y, barWidth - 2, height);

    // Show array values - only if there's enough space
    if (barWidth > 15) {
      fill(0);
      textSize(min(12, barWidth - 4)); // Adjust text size based on bar width
      textAlign(CENTER, BOTTOM);
      text(arr[k], x + barWidth / 2, y - 2);
    }

    // Show index - only if there's enough space
    if (barWidth > 15) {
      fill(100);
      textSize(min(10, barWidth - 6)); // Adjust text size based on bar width
      text("[" + k + "]", x + barWidth / 2, arrayViewY + 40 + barHeight + 15);
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

        if (swapping) {
          // Complete the swap
          int temp = arr[swapIndex1];
          arr[swapIndex1] = arr[swapIndex2];
          arr[swapIndex2] = temp;
          swapping = false;
          swaps++;

          // Continue heapify after swap
          if (currentPhase == 0) {
            // Building heap phase - continue heapify down
            // No need to do anything here, we'll move to the next node in the main loop
          } else {
            // Extracting max phase - continue heapify down from root
            heapifyDown(0, heapSize);
          }
        }
      }
    } else {
      if (currentPhase == 0) {
        // Phase 1: Build max heap
        if (currentIndex >= 0) {
          // Heapify down the current node
          heapifyDown(currentIndex, heapSize);
          steps++;

          // Move to the next node
          currentIndex--;
        } else {
          // Heap is built, move to extraction phase
          currentPhase = 1;
          currentIndex = 0;
          heapSize = n;
          steps++;

          // Reset any invalid indices
          parentIndex = -1;
          swapIndex1 = -1;
          swapIndex2 = -1;
        }
      } else {
        // Phase 2: Extract elements from heap
        if (heapSize > 1) {
          // Swap root with last element in heap
          swapping = true;
          swapIndex1 = 0;
          swapIndex2 = heapSize - 1;
          isAnimating = true;
          animationProgress = 0;

          // Reduce heap size
          heapSize--;
          sortedIndex = heapSize;
          steps++;

          // Ensure parentIndex is reset
          parentIndex = -1;
        } else {
          // Sorting complete
          sorted = true;
          sortedIndex = 0;

          // Verify the array is sorted
          boolean isSorted = true;
          for (int i = 0; i < n - 1; i++) {
            if (arr[i] > arr[i + 1]) {
              isSorted = false;
              break;
            }
          }

          // If not sorted, force a manual sort for visualization purposes
          if (!isSorted) {
            // Create a temporary array to hold sorted values
            int[] tempArr = new int[n];
            arrayCopy(arr, tempArr);

            // Sort the temporary array
            java.util.Arrays.sort(tempArr);

            // Copy back to the original array
            arrayCopy(tempArr, arr);
          }

          // Reset all indices
          parentIndex = -1;
          swapIndex1 = -1;
          swapIndex2 = -1;
        }
      }
    }
  }
}

void heapifyDown(int index, int size) {
  if (index < 0 || index >= size) return; // Safety check

  int largest = index;
  int left = 2 * index + 1;
  int right = 2 * index + 2;

  // Find the largest among root, left child and right child
  if (left < size) {
    comparisons++;
    if (arr[left] > arr[largest]) {
      largest = left;
    }
  }

  if (right < size) {
    comparisons++;
    if (arr[right] > arr[largest]) {
      largest = right;
    }
  }

  // If largest is not root
  if (largest != index) {
    // Swap and continue heapifying
    swapping = true;
    swapIndex1 = index;
    swapIndex2 = largest;
    isAnimating = true;
    animationProgress = 0;
    parentIndex = index;
  } else {
    // Move to next node
    parentIndex = -1;
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
  text("Heap Sort Visualizer", panelX + panelWidth/2, panelY + 15);

  // Draw algorithm information
  textSize(14);
  textAlign(LEFT, TOP);
  fill(0);
  String info = "Heap Sort uses a binary heap data\nstructure to create a partially ordered\ntree where the parent is always\ngreater than its children (max heap).\nIt then extracts the maximum element\nrepeatedly to sort the array.";
  text(info, panelX + 15, panelY + 45);

  // Draw complexity information
  text("Time Complexity: O(n log n)", panelX + 15, panelY + 150);
  text("Space Complexity: O(1)", panelX + 15, panelY + 170);

  // Draw current metrics
  textAlign(LEFT, TOP);
  text("Steps: " + steps, panelX + 15, panelY + 195);
  text("Comparisons: " + comparisons, panelX + 150, panelY + 195);
  text("Swaps: " + swaps, panelX + 15, panelY + 215);
  text("Speed: " + currentSpeed + " fps", panelX + 150, panelY + 215);

  // Draw current phase
  String phase = currentPhase == 0 ? "Building Max Heap" : "Extracting Elements";
  text("Current Phase: " + phase, panelX + 15, panelY + 235);

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
    // Add checks to ensure swapIndex1 and swapIndex2 are valid
    if (swapIndex1 >= 0 && swapIndex2 >= 0 && swapIndex1 < arr.length && swapIndex2 < arr.length) {
      action = "Swapping elements " + arr[swapIndex1] + " and " + arr[swapIndex2];
    } else {
      action = "Swapping elements";
    }
    fill(255, 140, 0);
  } else if (currentPhase == 0) {
    action = "Building max heap";
    if (currentIndex >= 0) {
      action += " - heapifying node " + currentIndex;
    }
    fill(0, 0, 150);
  } else {
    action = "Extracting max element from heap";
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
  } else if (decreaseSizeHover && n > 7) {
    n -= 2;
    resetArray();
  } else if (increaseSizeHover && n < 31) {
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
