int[] arr;
int n;
boolean sorted;
int i, j;
boolean paused = false;

void setup() {
  size(1000, 700);
  n = 50; // Number of elements
  arr = new int[n];
  for (int k = 0; k < n; k++) {
    arr[k] = int(random(height));
  }
  i = 1; // Start from the second element
  j = 0;
  sorted = false;
  frameRate(30); // Adjust speed of visualization
}

void draw() {
  background(255);
  
  // Draw the array as bars
  for (int k = 0; k < n; k++) {
    if (k == i) {
      fill(0, 255, 0); // Highlight the element being inserted
    } else if (k <= j && k >= i) {
      fill(255, 0, 0); // Highlight elements being compared
    } else {
      fill(0, 0, 255); // Default color
    }
    rect(k * (width / n), height - arr[k], width / n, arr[k]);
    
    // Show array values
    fill(0);
    textSize(12);
    textAlign(CENTER, BOTTOM);
    text(arr[k], k * (width / n) + (width / n) / 2, height - arr[k] - 5);
  }

  if (!paused && !sorted) {
    if (i < n) {
      if (j >= 0 && arr[j] > arr[j + 1]) {
        // Swap elements
        int temp = arr[j];
        arr[j] = arr[j + 1];
        arr[j + 1] = temp;
        j--;
      } else {
        i++;
        j = i - 1;
      }

      if (i >= n) {
        sorted = true; // Sorting is complete
      }
    }
  }

  // Indicate sorted completion
  if (sorted) {
    fill(0, 255, 0);
    textSize(32);
    textAlign(CENTER, CENTER);
    text("Sorted!", width / 2, height / 2);
  }
}

void keyPressed() {
  if (key == 'p') {
    paused = !paused;
    if (paused) {
      noLoop(); // Stop drawing
    } else {
      loop(); // Resume drawing
    }
  } else if (key == '+') {
    frameRate(frameRate + 5);
  } else if (key == '-') {
    frameRate(frameRate - 5);
  }
}
