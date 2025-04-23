// Binary Search Tree Visualization
// This visualizer demonstrates BST operations: insertion, search, deletion and traversal
// Enhanced version with educational features and improved visualization

// Tree node class
class Node {
  int value;
  Node left;
  Node right;
  float x, y; // Position for visualization
  float targetX, targetY; // Target position for animations
  boolean highlighted = false;
  boolean found = false;
  boolean isNew = false;
  boolean isDeleting = false;
  int height = 1; // Height of the node (for educational purposes)
  int balanceFactor = 0; // Balance factor (for educational purposes)
  color nodeColor = color(149, 165, 166); // Default node color
  float animationSpeed = 1.0; // Individual animation speed multiplier

  Node(int value) {
    this.value = value;
    this.left = null;
    this.right = null;
  }

  // Calculate height of this node based on its children
  void updateHeight() {
    int leftHeight = (left == null) ? 0 : left.height;
    int rightHeight = (right == null) ? 0 : right.height;
    height = 1 + max(leftHeight, rightHeight);
    balanceFactor = rightHeight - leftHeight;
  }
}

// BST variables
Node root = null;
int nodeSize = 40;
float animationProgress = 0;
boolean isAnimating = false;
int currentSpeed = 10;
boolean paused = false;
boolean showNodeProperties = true; // Show height and balance factor
boolean fullScreen = false; // Fullscreen mode

// Operation tracking
String currentOperation = "None";
int searchValue = -1;
int insertValue = -1;
Node currentNode = null;
boolean operationComplete = true;

// Traversal variables
ArrayList<Node> traversalPath = new ArrayList<Node>();
int currentTraversalIndex = 0;
boolean traversalInProgress = false;
int traversalDelay = 0;
int traversalSpeed = 15; // Frames between steps

// UI variables
int treeViewX, treeViewY, treeViewWidth, treeViewHeight;
int panelX, panelY, panelWidth, panelHeight;
int codeViewX, codeViewY, codeViewWidth, codeViewHeight;
int inputValue = 50;
String inputText = "50"; // Text field input
boolean inputActive = false; // Is text field active
boolean showCodeView = true; // Show pseudocode panel

// Buttons
ArrayList<Button> buttons = new ArrayList<Button>();

void setup() {
  size(1200, 800);
  frameRate(60);

  // Set up the layout
  setupLayout();

  // Insert some initial nodes
  insertNode(50);
  insertNode(30);
  insertNode(70);
  insertNode(20);
  insertNode(40);
  insertNode(60);
  insertNode(80);
}

void setupLayout() {
  // Clear existing buttons
  buttons.clear();

  // Set up visualization areas
  treeViewX = 20;
  treeViewY = 20;
  treeViewWidth = width - 300;
  treeViewHeight = height - 100;

  panelX = width - 260;
  panelY = 20;
  panelWidth = 240;
  panelHeight = 500;

  // Set up code view panel
  codeViewX = 20;
  codeViewY = height - 120;
  codeViewWidth = width - 300;
  codeViewHeight = 110;

  // Create buttons with more vertical spacing
  buttons.add(new Button("Insert", panelX + 20, panelY + 100, 200, 40));
  buttons.add(new Button("Search", panelX + 20, panelY + 150, 200, 40));
  buttons.add(new Button("Delete", panelX + 20, panelY + 200, 200, 40));
  buttons.add(new Button("In-order", panelX + 20, panelY + 250, 95, 40));
  buttons.add(new Button("Pre-order", panelX + 125, panelY + 250, 95, 40));
  buttons.add(new Button("Post-order", panelX + 20, panelY + 300, 95, 40));
  buttons.add(new Button("Level-order", panelX + 125, panelY + 300, 95, 40));
  buttons.add(new Button("Reset", panelX + 20, panelY + 350, 200, 40));

  // Add toggle buttons
  buttons.add(new Button("Toggle Properties", panelX + 20, panelY + 400, 95, 30));
  buttons.add(new Button("Toggle Code", panelX + 125, panelY + 400, 95, 30));

  // Add stop button for traversals
  buttons.add(new Button("Stop Traversal", panelX + 20, panelY + 490, 200, 30));
}

void draw() {
  background(240);

  // Draw tree view
  drawTreeView();

  // Draw control panel
  drawControlPanel();

  // Draw buttons
  for (Button button : buttons) {
    button.display();
  }

  // Update animations
  if (isAnimating) {
    animationProgress += 0.05 * currentSpeed;
    if (animationProgress >= 1) {
      animationProgress = 0;
      isAnimating = false;

      // Complete the current operation
      if (currentOperation.equals("Insert")) {
        completeInsert();
      } else if (currentOperation.equals("Search")) {
        completeSearch();
      } else if (currentOperation.equals("Delete")) {
        completeDelete();
      }

      operationComplete = true;
    }
  }

  // Update traversal animation
  if (traversalInProgress) {
    traversalDelay++;
    if (traversalDelay >= traversalSpeed) {
      traversalDelay = 0;

      // Move to next node in traversal
      if (currentTraversalIndex < traversalPath.size()) {
        // Reset previous node if not the first one
        if (currentTraversalIndex > 0) {
          traversalPath.get(currentTraversalIndex - 1).highlighted = false;
        }

        // Highlight current node
        Node currentNode = traversalPath.get(currentTraversalIndex);
        currentNode.highlighted = true;

        // Print current node value
        print(currentNode.value + " ");

        // Move to next node
        currentTraversalIndex++;
      } else {
        // Traversal complete
        traversalInProgress = false;
        println(); // New line after traversal
      }
    }
  }

  // Draw controls legend
  drawControlsLegend();

  // Draw code view panel if enabled
  if (showCodeView) {
    drawCodeView();
  }
}

void drawTreeView() {
  // Draw tree view background
  fill(255, 255, 255, 50);
  stroke(70, 130, 180);
  strokeWeight(1);
  rect(treeViewX, treeViewY, treeViewWidth, treeViewHeight, 5);

  // Draw tree title
  fill(25, 25, 112);
  textSize(18);
  textAlign(LEFT, TOP);
  text("Binary Search Tree", treeViewX + 10, treeViewY + 10);

  // Draw the tree
  if (root != null) {
    calculateNodePositions();
    drawNode(root);
  } else {
    // Draw empty tree message
    fill(100);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Tree is empty. Insert nodes to begin.", treeViewX + treeViewWidth/2, treeViewY + treeViewHeight/2);
  }
}

void drawControlPanel() {
  // Draw panel background
  fill(255);
  stroke(70, 130, 180);
  strokeWeight(1);
  rect(panelX, panelY, panelWidth, panelHeight, 5);

  // Draw panel title
  fill(25, 25, 112);
  textSize(18);
  textAlign(LEFT, TOP);
  text("BST Operations", panelX + 10, panelY + 10);

  // Draw current operation
  fill(0);
  textSize(14);
  text("Current Operation: " + currentOperation, panelX + 10, panelY + 40);

  // Draw input field label
  fill(0);
  textAlign(LEFT, CENTER);
  text("Value:", panelX + 20, panelY + 60);

  // Draw text input field
  if (inputActive) {
    fill(255); // White background when active
    stroke(41, 128, 185); // Blue border when active
    strokeWeight(2);
  } else {
    fill(240); // Light gray background when inactive
    stroke(100);
    strokeWeight(1);
  }
  rect(panelX + 20, panelY + 70, 200, 30, 5);

  // Draw text in input field
  fill(0);
  textAlign(LEFT, CENTER);
  text(inputText + (inputActive ? "|" : ""), panelX + 30, panelY + 85);

  // Draw input field instructions
  fill(100);
  textSize(10);
  text("Click to edit, Enter to confirm", panelX + 20, panelY + 110);
  textSize(14);

  // Draw traversal speed control
  fill(0);
  textAlign(LEFT, CENTER);
  text("Traversal Speed:", panelX + 20, panelY + 440);

  // Draw speed slider background
  fill(240);
  stroke(100);
  rect(panelX + 20, panelY + 450, 200, 20);

  // Draw speed slider handle
  float sliderPosition = map(traversalSpeed, 30, 5, panelX + 20, panelX + 220);
  fill(70, 130, 180);
  rect(sliderPosition - 5, panelY + 445, 10, 30);

  // Draw speed labels
  textSize(12);
  textAlign(LEFT, TOP);
  text("Slow", panelX + 20, panelY + 475);
  textAlign(RIGHT, TOP);
  text("Fast", panelX + 220, panelY + 475);
}

void drawNode(Node node) {
  if (node == null) return;

  // Draw connections to children
  stroke(70, 130, 180);
  strokeWeight(1);
  if (node.left != null) {
    line(node.x, node.y, node.left.x, node.left.y);
  }
  if (node.right != null) {
    line(node.x, node.y, node.right.x, node.right.y);
  }

  // Draw children first (so parent appears on top)
  drawNode(node.left);
  drawNode(node.right);

  // Update node height and balance factor
  node.updateHeight();

  // Determine node color
  if (node.isDeleting) {
    fill(231, 76, 60); // Red for nodes being deleted
    stroke(192, 57, 43);
    strokeWeight(2);
  } else if (node.found) {
    fill(46, 204, 113); // Green for found nodes
    stroke(39, 174, 96);
    strokeWeight(2);
  } else if (node.highlighted) {
    fill(241, 196, 15); // Yellow for highlighted nodes (current)
    stroke(243, 156, 18);
    strokeWeight(2);
  } else if (node.isNew) {
    fill(52, 152, 219); // Blue for newly inserted nodes
    stroke(41, 128, 185);
    strokeWeight(2);
  } else {
    // Color based on balance factor
    if (abs(node.balanceFactor) > 1) {
      // Unbalanced node
      fill(230, 126, 34); // Orange for unbalanced nodes
      stroke(211, 84, 0);
      strokeWeight(2);
    } else {
      fill(149, 165, 166); // Gray for normal nodes
      stroke(127, 140, 141);
      strokeWeight(1);
    }
  }

  // Draw the node circle
  ellipse(node.x, node.y, nodeSize, nodeSize);

  // Draw node value
  fill(255);
  textSize(14);
  textAlign(CENTER, CENTER);
  text(node.value, node.x, node.y);

  // Draw height and balance factor
  if (showNodeProperties) {
    textSize(10);
    fill(50);
    text("h:" + node.height, node.x, node.y + nodeSize/2 + 12);

    // Color-code balance factor
    if (abs(node.balanceFactor) > 1) {
      fill(211, 84, 0); // Orange for unbalanced
    } else if (abs(node.balanceFactor) == 1) {
      fill(243, 156, 18); // Yellow for slightly unbalanced
    } else {
      fill(39, 174, 96); // Green for balanced
    }
    text("bf:" + node.balanceFactor, node.x, node.y + nodeSize/2 + 24);
  }
}

void calculateNodePositions() {
  if (root == null) return;

  // Calculate the maximum depth of the tree
  int maxDepth = getMaxDepth(root);

  // Calculate vertical spacing
  float verticalSpacing = min(80, (treeViewHeight - 100) / maxDepth);

  // Set root position
  root.x = treeViewX + treeViewWidth / 2;
  root.y = treeViewY + 60;
  root.targetX = root.x;
  root.targetY = root.y;

  // Calculate positions for all nodes
  calculatePositions(root, 0, treeViewWidth / 4, verticalSpacing);

  // Adjust positions to ensure all nodes are within bounds
  adjustNodePositions();
}

int getMaxDepth(Node node) {
  if (node == null) return 0;
  return 1 + max(getMaxDepth(node.left), getMaxDepth(node.right));
}

void calculatePositions(Node node, int level, float xOffset, float ySpacing) {
  if (node == null) return;

  // Calculate positions for children
  if (node.left != null) {
    node.left.x = node.x - xOffset;
    node.left.y = node.y + ySpacing;
    node.left.targetX = node.left.x;
    node.left.targetY = node.left.y;
    calculatePositions(node.left, level + 1, xOffset / 2, ySpacing);
  }

  if (node.right != null) {
    node.right.x = node.x + xOffset;
    node.right.y = node.y + ySpacing;
    node.right.targetX = node.right.x;
    node.right.targetY = node.right.y;
    calculatePositions(node.right, level + 1, xOffset / 2, ySpacing);
  }
}

void adjustNodePositions() {
  // Find leftmost and rightmost node positions
  float leftmost = treeViewX + treeViewWidth;
  float rightmost = treeViewX;
  findExtremePositions(root, leftmost, rightmost);

  // Check if any nodes are outside the view boundaries
  float leftMargin = 40;
  float rightMargin = 40;

  if (leftmost < treeViewX + leftMargin || rightmost > treeViewX + treeViewWidth - rightMargin) {
    // Calculate scaling factor to fit within boundaries
    float availableWidth = treeViewWidth - leftMargin - rightMargin;
    float currentWidth = rightmost - leftmost;
    float scaleFactor = min(1.0, availableWidth / currentWidth);

    // Center point for scaling
    float centerX = treeViewX + treeViewWidth / 2;

    // Apply scaling to all nodes
    scaleNodePositions(root, centerX, scaleFactor);
  }
}

void findExtremePositions(Node node, float leftmost, float rightmost) {
  if (node == null) return;

  leftmost = min(leftmost, node.x);
  rightmost = max(rightmost, node.x);

  findExtremePositions(node.left, leftmost, rightmost);
  findExtremePositions(node.right, leftmost, rightmost);
}

void scaleNodePositions(Node node, float centerX, float scaleFactor) {
  if (node == null) return;

  // Scale x position relative to center
  float distanceFromCenter = node.x - centerX;
  node.x = centerX + distanceFromCenter * scaleFactor;
  node.targetX = node.x;

  // Scale children
  scaleNodePositions(node.left, centerX, scaleFactor);
  scaleNodePositions(node.right, centerX, scaleFactor);
}

// BST Operations
void insertNode(int value) {
  root = insert(root, value);
  resetNodeStates();
}

Node insert(Node node, int value) {
  if (node == null) {
    Node newNode = new Node(value);
    newNode.isNew = true;
    return newNode;
  }

  if (value < node.value) {
    node.left = insert(node.left, value);
  } else if (value > node.value) {
    node.right = insert(node.right, value);
  }

  return node;
}

void searchNode(int value) {
  resetNodeStates();
  search(root, value);
}

boolean search(Node node, int value) {
  if (node == null) return false;

  if (node.value == value) {
    node.found = true;
    return true;
  }

  node.highlighted = true;

  if (value < node.value) {
    return search(node.left, value);
  } else {
    return search(node.right, value);
  }
}

void deleteNode(int value) {
  resetNodeStates();
  root = delete(root, value);
}

Node delete(Node node, int value) {
  if (node == null) return null;

  if (value < node.value) {
    node.highlighted = true;
    node.left = delete(node.left, value);
  } else if (value > node.value) {
    node.highlighted = true;
    node.right = delete(node.right, value);
  } else {
    // Node to be deleted found
    node.isDeleting = true;

    // Case 1: Leaf node
    if (node.left == null && node.right == null) {
      return null;
    }

    // Case 2: Node with only one child
    if (node.left == null) {
      return node.right;
    }
    if (node.right == null) {
      return node.left;
    }

    // Case 3: Node with two children
    // Find the inorder successor (smallest node in right subtree)
    node.value = minValue(node.right);

    // Delete the inorder successor
    node.right = delete(node.right, node.value);
  }

  return node;
}

int minValue(Node node) {
  int minv = node.value;
  while (node.left != null) {
    minv = node.left.value;
    node = node.left;
  }
  return minv;
}

void resetNodeStates() {
  resetStates(root);
}

void resetStates(Node node) {
  if (node == null) return;

  node.highlighted = false;
  node.found = false;
  node.isNew = false;
  node.isDeleting = false;

  resetStates(node.left);
  resetStates(node.right);
}

// Animation completions
void completeInsert() {
  insertNode(insertValue);
}

void completeSearch() {
  searchNode(searchValue);
}

void completeDelete() {
  deleteNode(insertValue);
}

// Traversals
void inOrderTraversal() {
  resetNodeStates();
  currentOperation = "In-order Traversal";
  println("In-order Traversal:");

  // Clear previous traversal path
  traversalPath.clear();
  currentTraversalIndex = 0;

  // Generate traversal path
  generateInOrderPath(root);

  // Start traversal animation
  traversalInProgress = true;
  traversalDelay = 0;
}

void generateInOrderPath(Node node) {
  if (node == null) return;

  generateInOrderPath(node.left);
  traversalPath.add(node);
  generateInOrderPath(node.right);
}

void preOrderTraversal() {
  resetNodeStates();
  currentOperation = "Pre-order Traversal";
  println("Pre-order Traversal:");

  // Clear previous traversal path
  traversalPath.clear();
  currentTraversalIndex = 0;

  // Generate traversal path
  generatePreOrderPath(root);

  // Start traversal animation
  traversalInProgress = true;
  traversalDelay = 0;
}

void generatePreOrderPath(Node node) {
  if (node == null) return;

  traversalPath.add(node);
  generatePreOrderPath(node.left);
  generatePreOrderPath(node.right);
}

void postOrderTraversal() {
  resetNodeStates();
  currentOperation = "Post-order Traversal";
  println("Post-order Traversal:");

  // Clear previous traversal path
  traversalPath.clear();
  currentTraversalIndex = 0;

  // Generate traversal path
  generatePostOrderPath(root);

  // Start traversal animation
  traversalInProgress = true;
  traversalDelay = 0;
}

void generatePostOrderPath(Node node) {
  if (node == null) return;

  generatePostOrderPath(node.left);
  generatePostOrderPath(node.right);
  traversalPath.add(node);
}

void levelOrderTraversal() {
  resetNodeStates();
  currentOperation = "Level-order Traversal";
  println("Level-order Traversal:");

  // Clear previous traversal path
  traversalPath.clear();
  currentTraversalIndex = 0;

  // Generate level order traversal path
  int h = getMaxDepth(root);
  for (int i = 1; i <= h; i++) {
    generateLevelOrderPath(root, i);
  }

  // Start traversal animation
  traversalInProgress = true;
  traversalDelay = 0;
}

void generateLevelOrderPath(Node node, int level) {
  if (node == null) return;

  if (level == 1) {
    traversalPath.add(node);
  } else if (level > 1) {
    generateLevelOrderPath(node.left, level - 1);
    generateLevelOrderPath(node.right, level - 1);
  }
}

void drawControlsLegend() {
  fill(255);
  stroke(70, 130, 180);
  strokeWeight(1);
  rect(panelX, panelY + panelHeight + 20, panelWidth, 220, 5);

  fill(0);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Controls:", panelX + 10, panelY + panelHeight + 30);
  textSize(14);
  text("P - Pause/Resume", panelX + 10, panelY + panelHeight + 55);
  text("+ - Increase Animation Speed", panelX + 10, panelY + panelHeight + 75);
  text("- - Decrease Animation Speed", panelX + 10, panelY + panelHeight + 95);
  text("R - Reset Tree", panelX + 10, panelY + panelHeight + 115);
  text("H - Toggle Node Properties", panelX + 10, panelY + panelHeight + 135);
  text("C - Toggle Code View", panelX + 10, panelY + panelHeight + 155);
  text("F - Toggle Fullscreen", panelX + 10, panelY + panelHeight + 175);
  text("S - Stop Traversal", panelX + 10, panelY + panelHeight + 195);
  text("↑/↓ - Adjust Traversal Speed", panelX + 10, panelY + panelHeight + 215);

  // Draw traversal status if in progress
  if (traversalInProgress) {
    fill(46, 204, 113);
    textAlign(LEFT, TOP);
    text("Traversal in progress: " + currentTraversalIndex + "/" + traversalPath.size(),
         panelX + 10, panelY + panelHeight + 240);
  }
}

void drawCodeView() {
  // Draw code view background
  fill(255);
  stroke(70, 130, 180);
  strokeWeight(1);
  rect(codeViewX, codeViewY, codeViewWidth, codeViewHeight, 5);

  // Draw title
  fill(25, 25, 112);
  textSize(14);
  textAlign(LEFT, TOP);
  text("Pseudocode:", codeViewX + 10, codeViewY + 5);

  // Draw pseudocode based on current operation
  fill(0);
  textSize(12);
  textAlign(LEFT, TOP);

  String pseudocode = "";

  if (currentOperation.equals("Insert")) {
    pseudocode = "insert(node, value): if node is null, return new Node(value); if value < node.value, node.left = insert(node.left, value); else if value > node.value, node.right = insert(node.right, value); return node";
  } else if (currentOperation.equals("Search")) {
    pseudocode = "search(node, value): if node is null, return false; if node.value equals value, return true; if value < node.value, return search(node.left, value); else return search(node.right, value)";
  } else if (currentOperation.equals("Delete")) {
    pseudocode = "delete(node, value): if node is null, return null; if value < node.value, node.left = delete(node.left, value); else if value > node.value, node.right = delete(node.right, value); else handle leaf, one child, or two children cases";
  } else if (currentOperation.equals("In-order Traversal")) {
    pseudocode = "inOrder(node): if node is null, return; inOrder(node.left); visit(node); inOrder(node.right)";

    // Add traversal progress information if in progress
    if (traversalInProgress && traversalPath.size() > 0) {
      pseudocode += "\n\nTraversal Progress: " + currentTraversalIndex + "/" + traversalPath.size();
      if (currentTraversalIndex > 0 && currentTraversalIndex <= traversalPath.size()) {
        pseudocode += "\nCurrent Node: " + traversalPath.get(currentTraversalIndex - 1).value;
      }
    }
  } else if (currentOperation.equals("Pre-order Traversal")) {
    pseudocode = "preOrder(node): if node is null, return; visit(node); preOrder(node.left); preOrder(node.right)";

    // Add traversal progress information if in progress
    if (traversalInProgress && traversalPath.size() > 0) {
      pseudocode += "\n\nTraversal Progress: " + currentTraversalIndex + "/" + traversalPath.size();
      if (currentTraversalIndex > 0 && currentTraversalIndex <= traversalPath.size()) {
        pseudocode += "\nCurrent Node: " + traversalPath.get(currentTraversalIndex - 1).value;
      }
    }
  } else if (currentOperation.equals("Post-order Traversal")) {
    pseudocode = "postOrder(node): if node is null, return; postOrder(node.left); postOrder(node.right); visit(node)";

    // Add traversal progress information if in progress
    if (traversalInProgress && traversalPath.size() > 0) {
      pseudocode += "\n\nTraversal Progress: " + currentTraversalIndex + "/" + traversalPath.size();
      if (currentTraversalIndex > 0 && currentTraversalIndex <= traversalPath.size()) {
        pseudocode += "\nCurrent Node: " + traversalPath.get(currentTraversalIndex - 1).value;
      }
    }
  } else if (currentOperation.equals("Level-order Traversal")) {
    pseudocode = "levelOrder(root): for each level from 1 to height of tree: printLevel(root, level)";

    // Add traversal progress information if in progress
    if (traversalInProgress && traversalPath.size() > 0) {
      pseudocode += "\n\nTraversal Progress: " + currentTraversalIndex + "/" + traversalPath.size();
      if (currentTraversalIndex > 0 && currentTraversalIndex <= traversalPath.size()) {
        pseudocode += "\nCurrent Node: " + traversalPath.get(currentTraversalIndex - 1).value;
      }
    }
  } else {
    pseudocode = "Select an operation to see its pseudocode";
  }

  // Draw pseudocode with word wrapping
  int maxWidth = codeViewWidth - 20;
  int x = codeViewX + 10;
  int y = codeViewY + 25;

  String[] words = pseudocode.split(" ");
  String line = "";

  for (String word : words) {
    float lineWidth = textWidth(line + word + " ");
    if (lineWidth > maxWidth && !line.isEmpty()) {
      text(line, x, y);
      line = word + " ";
      y += 15; // Move to next line
    } else {
      line += word + " ";
    }
  }

  // Draw the last line
  if (!line.isEmpty()) {
    text(line, x, y);
  }
}

// Button class
class Button {
  String label;
  float x, y, w, h;
  boolean isHovered = false;

  Button(String label, float x, float y, float w, float h) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void display() {
    // Check if mouse is over the button
    isHovered = mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;

    // Draw button
    if (isHovered) {
      fill(100, 149, 237); // Hover color
    } else {
      fill(70, 130, 180); // Normal color
    }
    stroke(25, 25, 112);
    strokeWeight(1);
    rect(x, y, w, h, 5);

    // Draw label
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(14);
    text(label, x + w/2, y + h/2);
  }

  boolean isClicked() {
    return isHovered && mousePressed;
  }
}

void mousePressed() {
  // Check for button clicks
  for (Button button : buttons) {
    if (button.isHovered) {
      if (button.label.equals("Insert")) {
        currentOperation = "Insert";
        insertValue = inputValue;
        isAnimating = true;
        animationProgress = 0;
        operationComplete = false;
      } else if (button.label.equals("Search")) {
        currentOperation = "Search";
        searchValue = inputValue;
        isAnimating = true;
        animationProgress = 0;
        operationComplete = false;
      } else if (button.label.equals("Delete")) {
        currentOperation = "Delete";
        insertValue = inputValue;
        isAnimating = true;
        animationProgress = 0;
        operationComplete = false;
      } else if (button.label.equals("In-order")) {
        inOrderTraversal();
      } else if (button.label.equals("Pre-order")) {
        preOrderTraversal();
      } else if (button.label.equals("Post-order")) {
        postOrderTraversal();
      } else if (button.label.equals("Level-order")) {
        levelOrderTraversal();
      } else if (button.label.equals("Reset")) {
        root = null;
        currentOperation = "None";
        traversalInProgress = false;
      } else if (button.label.equals("Toggle Properties")) {
        showNodeProperties = !showNodeProperties;
      } else if (button.label.equals("Toggle Code")) {
        showCodeView = !showCodeView;
      } else if (button.label.equals("Stop Traversal")) {
        if (traversalInProgress) {
          traversalInProgress = false;
          resetNodeStates();
          println("\nTraversal stopped.");
        }
      }
    }
  }

  // Check for text field click
  if (mouseX >= panelX + 20 && mouseX <= panelX + 220 && mouseY >= panelY + 70 && mouseY <= panelY + 100) {
    inputActive = true;
  } else {
    // If clicked outside the text field, deactivate it and update the value
    if (inputActive) {
      inputActive = false;
      try {
        inputValue = Integer.parseInt(inputText);
      } catch (NumberFormatException e) {
        // If input is not a valid number, reset to previous value
        inputText = str(inputValue);
      }
    }
  }

  // Check for traversal speed slider interaction
  if (mouseX >= panelX + 20 && mouseX <= panelX + 220 &&
      mouseY >= panelY + 445 && mouseY <= panelY + 475) {
    // Map mouse position to traversal speed
    traversalSpeed = int(map(mouseX, panelX + 20, panelX + 220, 30, 5));
    traversalSpeed = constrain(traversalSpeed, 5, 30);
  }
}

void keyPressed() {
  // Handle text input when input field is active
  if (inputActive) {
    if (key == ENTER || key == RETURN) {
      // Confirm input
      inputActive = false;
      try {
        inputValue = Integer.parseInt(inputText);
      } catch (NumberFormatException e) {
        // If input is not a valid number, reset to previous value
        inputText = str(inputValue);
      }
    } else if (key == BACKSPACE) {
      // Handle backspace
      if (inputText.length() > 0) {
        inputText = inputText.substring(0, inputText.length() - 1);
      }
    } else if (key >= '0' && key <= '9') {
      // Only allow numeric input
      inputText += key;
    }
    return; // Don't process other keys when input is active
  }

  // Normal key handling when input field is not active
  if (key == 'p' || key == 'P') {
    paused = !paused;
    if (paused) {
      noLoop();
    } else {
      loop();
    }
  } else if (key == '+') {
    currentSpeed = min(currentSpeed + 1, 20);
  } else if (key == '-') {
    currentSpeed = max(currentSpeed - 1, 1);
  } else if (key == 'r' || key == 'R') {
    root = null;
    currentOperation = "None";
    traversalInProgress = false;
  } else if (key == 'h' || key == 'H') {
    // Toggle node properties display
    showNodeProperties = !showNodeProperties;
  } else if (key == 'c' || key == 'C') {
    // Toggle code view
    showCodeView = !showCodeView;
  } else if (key == 'f' || key == 'F') {
    // Toggle fullscreen
    if (fullScreen) {
      size(1200, 800);
      fullScreen = false;
    } else {
      fullScreen();
      fullScreen = true;
    }
    // Recalculate layout
    setupLayout();
  } else if (key == 's' || key == 'S') {
    // Stop any traversal in progress
    if (traversalInProgress) {
      traversalInProgress = false;
      resetNodeStates();
      println("\nTraversal stopped.");
    }
  } else if (key == CODED) {
    if (keyCode == UP) {
      // Speed up traversal
      traversalSpeed = max(traversalSpeed - 2, 5);
    } else if (keyCode == DOWN) {
      // Slow down traversal
      traversalSpeed = min(traversalSpeed + 2, 30);
    }
  }
}