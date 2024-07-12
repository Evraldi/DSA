import pygame
import sys

# Initialize Pygame
pygame.init()

# Constants
SCREEN_WIDTH = 900
SCREEN_HEIGHT = 700
STACK_SIZE = 10  # Fixed size of the stack
ITEM_WIDTH = 80
ITEM_HEIGHT = 60
ITEM_COLOR = (255, 0, 0)  # Red
BACKGROUND_COLOR = (240, 240, 240)  # Light gray
BUTTON_WIDTH = 140
BUTTON_HEIGHT = 50
BUTTON_COLOR = (0, 200, 0)  # Green
BUTTON_HOVER_COLOR = (0, 150, 0)  # Darker green
BUTTON_TEXT_COLOR = (255, 255, 255)  # White
TEXT_COLOR = (0, 0, 0)  # Black
FONT_SIZE = 30
MESSAGE_FONT_SIZE = 24
INSTRUCTION_FONT_SIZE = 20
STACK_BORDER_COLOR = (0, 0, 0)  # Black
STACK_BORDER_WIDTH = 2  # Adjust this value to change the stack border width
MESSAGE_BOX_HEIGHT = 60  # Height for message box
GRID_COLOR = (200, 200, 200)  # Light gray for grid
GRID_STEP = ITEM_HEIGHT + 10  # Grid step is based on item size
STACK_BORDER_BOTTOM_HEIGHT =  0 # Adjust this value to change the bottom height of the stack border

# Setup the screen
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption('Stack Visualization')

# Stack data structure
stack = []

# Button positions and labels
button_labels = ['Push', 'Pop', 'Peek', 'Is Empty', 'Is Full']
button_positions = {
    'Push': pygame.Rect(50, SCREEN_HEIGHT - BUTTON_HEIGHT - 10, BUTTON_WIDTH, BUTTON_HEIGHT),
    'Pop': pygame.Rect(200, SCREEN_HEIGHT - BUTTON_HEIGHT - 10, BUTTON_WIDTH, BUTTON_HEIGHT),
    'Peek': pygame.Rect(350, SCREEN_HEIGHT - BUTTON_HEIGHT - 10, BUTTON_WIDTH, BUTTON_HEIGHT),
    'Is Empty': pygame.Rect(500, SCREEN_HEIGHT - BUTTON_HEIGHT - 10, BUTTON_WIDTH, BUTTON_HEIGHT),
    'Is Full': pygame.Rect(650, SCREEN_HEIGHT - BUTTON_HEIGHT - 10, BUTTON_WIDTH, BUTTON_HEIGHT)
}

def draw_grid():
    """Draw a grid on the screen for better visualization."""
    for x in range(0, SCREEN_WIDTH, GRID_STEP):
        pygame.draw.line(screen, GRID_COLOR, (x, 100), (x, SCREEN_HEIGHT - BUTTON_HEIGHT - 10), 1)
    for y in range(100, SCREEN_HEIGHT - BUTTON_HEIGHT - 10, GRID_STEP):
        pygame.draw.line(screen, GRID_COLOR, (0, y), (SCREEN_WIDTH, y), 1)

def draw_stack():
    """Draw the stack and buttons on the screen."""
    screen.fill(BACKGROUND_COLOR)

    # Draw grid
    draw_grid()

    # Draw stack border
    stack_border_height = (ITEM_HEIGHT + 10) * STACK_SIZE + STACK_BORDER_BOTTOM_HEIGHT
    pygame.draw.rect(screen, STACK_BORDER_COLOR, 
                     (SCREEN_WIDTH // 2 - ITEM_WIDTH // 2 - 10, 100, ITEM_WIDTH + 20, stack_border_height), 
                     STACK_BORDER_WIDTH)

    # Draw stack items from bottom to top
    for i, item in enumerate(stack):
        y = 100 + (ITEM_HEIGHT + 10) * (STACK_SIZE - len(stack) + i)
        pygame.draw.rect(screen, ITEM_COLOR, (SCREEN_WIDTH // 2 - ITEM_WIDTH // 2, y, ITEM_WIDTH, ITEM_HEIGHT))
        pygame.draw.line(screen, STACK_BORDER_COLOR, 
                         (SCREEN_WIDTH // 2 - ITEM_WIDTH // 2, y), 
                         (SCREEN_WIDTH // 2 + ITEM_WIDTH // 2, y), 
                         STACK_BORDER_WIDTH)

    # Draw buttons
    for label, rect in button_positions.items():
        draw_button(rect, label)
    
    # Draw instructions
    draw_instructions()
    
    # Draw current message
    draw_message()

    pygame.display.flip()

def draw_button(rect, text):
    """Draw a button with text."""
    mouse_pos = pygame.mouse.get_pos()
    color = BUTTON_HOVER_COLOR if rect.collidepoint(mouse_pos) else BUTTON_COLOR
    pygame.draw.rect(screen, color, rect)
    draw_button_text(rect, text)

def draw_button_text(rect, text):
    """Draw text on a button."""
    font = pygame.font.Font(None, FONT_SIZE)
    text_surf = font.render(text, True, BUTTON_TEXT_COLOR)
    text_rect = text_surf.get_rect(center=rect.center)
    screen.blit(text_surf, text_rect)

def draw_instructions():
    """Draw instructional text on the screen."""
    font = pygame.font.Font(None, INSTRUCTION_FONT_SIZE)
    instructions = [
        "Instructions:",
        "1. Click 'Push' to add a new item to the stack.",
        "2. Click 'Pop' to remove the top item from the stack.",
        "3. Click 'Peek' to see the top item without removing it.",
        "4. Click 'Is Empty' to check if the stack is empty.",
        "5. Click 'Is Full' to check if the stack is full."
    ]
    x_offset = 20
    y_offset = 20
    for instruction in instructions:
        text_surf = font.render(instruction, True, TEXT_COLOR)
        screen.blit(text_surf, (x_offset, y_offset))
        y_offset += 30

def display_message(message):
    """Display a message on the screen."""
    global current_message
    current_message = message

def draw_message():
    """Draw the current message on the screen."""
    if current_message:
        font = pygame.font.Font(None, MESSAGE_FONT_SIZE)
        text_surf = font.render(current_message, True, TEXT_COLOR)
        text_rect = text_surf.get_rect(center=(SCREEN_WIDTH // 2, 50))
        pygame.draw.rect(screen, (255, 255, 255), (20, 10, SCREEN_WIDTH - 40, MESSAGE_BOX_HEIGHT))  # Background for the message
        pygame.draw.rect(screen, TEXT_COLOR, (20, 10, SCREEN_WIDTH - 40, MESSAGE_BOX_HEIGHT), 2)  # Border
        screen.blit(text_surf, text_rect)

def push():
    """Push an item onto the stack."""
    if len(stack) < STACK_SIZE:
        stack.append(len(stack) + 1)  # Push item with a value based on current stack length
        display_message(f"Pushed {stack[-1]}")
    else:
        display_message("Stack is full!")

def pop():
    """Pop an item from the stack."""
    if stack:
        item = stack.pop()
        display_message(f"Popped {item}")
    else:
        display_message("Stack is empty!")

def peek():
    """Peek at the top item of the stack."""
    if stack:
        item = stack[-1]
        display_message(f"Top item: {item}")
    else:
        display_message("Stack is empty!")

def is_empty():
    """Check if the stack is empty."""
    if not stack:
        display_message("Stack is empty!")
    else:
        display_message("Stack is not empty.")

def is_full():
    """Check if the stack is full."""
    if len(stack) >= STACK_SIZE:
        display_message("Stack is full!")
    else:
        display_message("Stack is not full.")

def main():
    """Main loop for the stack visualization with buttons."""
    global current_message
    current_message = ""
    clock = pygame.time.Clock()

    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            elif event.type == pygame.MOUSEBUTTONDOWN:
                mouse_pos = event.pos
                for label, rect in button_positions.items():
                    if rect.collidepoint(mouse_pos):
                        if label == 'Push':
                            push()
                        elif label == 'Pop':
                            pop()
                        elif label == 'Peek':
                            peek()
                        elif label == 'Is Empty':
                            is_empty()
                        elif label == 'Is Full':
                            is_full()

        draw_stack()
        clock.tick(30)

if __name__ == '__main__':
    main()
