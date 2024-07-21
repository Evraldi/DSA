import controlP5.*;
import java.util.ArrayList;

int[] arr = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 70, 60, 50, 40, 30, 20, 10, 5, 15, 25, 35, 45, 55, 65, 75, 85, 95, 105, 115, 125};
int currentIndex = 0;
boolean resetButtonClicked = false;
boolean startButtonClicked = false;
boolean[] path;
ArrayList<Integer> foundIndices;
ControlP5 cp5;
Textfield targetTextfield;
Textlabel errorLabel;
Slider speedSlider;
int animationSpeed = 10; // Kecepatan default animasi

void setup() {
  size(1200, 900); // Ukuran layar 
  noStroke();

  // Inisialisasi jalur pencarian
  path = new boolean[arr.length];
  for (int i = 0; i < path.length; i++) {
    path[i] = false;
  }

  foundIndices = new ArrayList<Integer>();

  cp5 = new ControlP5(this);
  
  PFont customFont = createFont("Arial", 24);
  
  // input teks untuk mengubah nilai target
  targetTextfield = cp5.addTextfield("targetTextfield")
                       .setPosition(10, height - 175)
                       .setSize(250, 50)
                       .setLabel("Target")
                       .setText("70")
                       .setColor(color(0, 0, 0))
                       .setColorBackground(color(220, 220, 220))
                       .setColorActive(color(0, 150, 255))
                       .setFont(customFont);

  // slider untuk mengatur kecepatan animasi
  speedSlider = cp5.addSlider("speedSlider")
                  .setPosition(270, height - 175)
                  .setSize(250, 50)
                  .setRange(5, 30)
                  .setValue(10)
                  .setLabel("Speed")
                  .setColorLabel(color(0, 0, 0))
                  .setColorActive(color(0, 150, 255))
                  .setFont(customFont);

  errorLabel = cp5.addTextlabel("errorLabel")
                   .setPosition(10, height - 50) 
                   .setSize(800, 30)
                   .setColor(color(255, 0, 0))
                   .setText("");
                   
  // Tombol reset
  cp5.addButton("resetButton")
     .setPosition(width - 150, height - 80)
     .setSize(130, 50)
     .setLabel("Reset")
     .setFont(customFont);

  // Tombol start
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
  frameRate(animationSpeed);

  // Area untuk animasi (bagian atas jendela)
  fill(255);
  rect(0, 0, width, height - 200);

  // Gambar area animasi
  for (int i = 0; i < arr.length; i++) {
    if (i == currentIndex) {
      fill(255, 0, 0); // Highlight elemen saat ini
    } else if (foundIndices.contains(i)) {
      fill(0, 255, 0); // Highlight elemen yang ditemukan
    } else if (path[i]) {
      fill(200, 200, 100); // Highlight jalur pencarian
    } else {
      fill(100, 150, 250); // Warna default
    }
    rect(i * barWidth, height - 200 - arr[i] * 3, barWidth - 1, arr[i] * 3);
  }

  fill(240);
  rect(0, height - 100, width, 100);

  fill(0);
  textSize(18);
  text("Current Index: " + currentIndex, 10, height - 20);
  text("Target: " + targetTextfield.getText(), 10, height - 40);
  text("Status: " + (foundIndices.isEmpty() ? "Searching" : "Found"), 10, height - 60);
  cp5.draw();

  // Logika pencarian linear
  if (startButtonClicked) {
    if (currentIndex < arr.length) {
      path[currentIndex] = true;
      if (arr[currentIndex] == Integer.parseInt(targetTextfield.getText())) {
        foundIndices.add(currentIndex);
      }
      currentIndex++;
    } else if (resetButtonClicked) {
      reset();
    }
  }
}

void resetButton() {
  resetButtonClicked = true;
}

void startButton() {
  startButtonClicked = true;
}

void reset() {
  currentIndex = 0;
  foundIndices.clear();
  resetButtonClicked = false;
  startButtonClicked = false;
  for (int i = 0; i < path.length; i++) {
    path[i] = false;
  }
}
