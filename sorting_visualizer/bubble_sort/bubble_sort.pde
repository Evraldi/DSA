int[] arr;
int n;
boolean sorted;
int i, j;
boolean paused = false;

void setup() {
  size(1000, 700);
  n = 30; // Number of elements
  arr = new int[n];
  for (int k = 0; k < n; k++) {
    arr[k] = int(random(height));
  }
  i = 0;
  j = 0;
  sorted = false;
  frameRate(10); // Adjust speed of visualization
}

void draw() {
  background(255);
  
  for (int k = 0; k < n; k++) {
    if (k == j || k == j + 1) {
      fill(255, 0, 0); // Highlight comparison
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
    if (j < n - i - 1) {
      if (arr[j] > arr[j + 1]) {
        int temp = arr[j];
        arr[j] = arr[j + 1];
        arr[j + 1] = temp;
      }
      j++;
    } else {
      j = 0;
      i++;
      if (i >= n - 1) {
        sorted = true;
      }
    }
  }

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
      noLoop();
    } else {
      loop();
    }
  } else if (key == '+') {
    frameRate(frameRate + 5);
  } else if (key == '-') {
    frameRate(frameRate - 5);
  }
}
