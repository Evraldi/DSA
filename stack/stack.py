import pygame
import sys

# Initialize Pygame
pygame.init()

# Constants
SCREEN_WIDTH = 900
SCREEN_HEIGHT = 700
STACK_SIZE = 7  # Further reduced stack size for better fit
ITEM_WIDTH = 80
ITEM_HEIGHT = 50  # Reduced height for better fit

# Colors - Modern color scheme
BACKGROUND_COLOR = (240, 240, 250)  # Light blue-grey
STACK_BORDER_COLOR = (70, 130, 180)  # Steel blue
ITEM_COLOR = (135, 206, 235)  # Sky blue
ITEM_BORDER_COLOR = (70, 130, 180)  # Steel blue
ITEM_TEXT_COLOR = (25, 25, 112)  # Midnight blue
TOP_INDICATOR_COLOR = (255, 140, 0)  # Darker orange
BUTTON_COLOR = (70, 130, 180)  # Steel blue
BUTTON_HOVER_COLOR = (100, 149, 237)  # Cornflower blue
BUTTON_TEXT_COLOR = (255, 255, 255)  # White
TEXT_COLOR = (25, 25, 112)  # Midnight blue
ERROR_COLOR = (220, 20, 60)  # Crimson
SUCCESS_COLOR = (46, 139, 87)  # Sea green
INDEX_COLOR = (100, 100, 100)  # Gray for index numbers
EMPTY_SLOT_COLOR = (220, 220, 230)  # Light gray for empty slots

# UI Settings
BUTTON_WIDTH = 140
BUTTON_HEIGHT = 50
FONT_SIZE = 30
MESSAGE_FONT_SIZE = 24
INSTRUCTION_FONT_SIZE = 20
STACK_BORDER_WIDTH = 3  # Thicker border
MESSAGE_BOX_HEIGHT = 60  # Height for message box
GRID_COLOR = (220, 220, 230)  # Lighter grid
GRID_STEP = ITEM_HEIGHT + 10  # Grid step is based on item size
STACK_BORDER_BOTTOM_HEIGHT = 10  # Add some padding at the bottom

# Setup the screen
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption('Stack Visualization')

# Stack data structure
stack = []

# Button positions and labels
button_labels = ['Push', 'Pop', 'Peek', 'Is Empty', 'Is Full']

# Move buttons even lower
button_y = SCREEN_HEIGHT - BUTTON_HEIGHT - 80
button_positions = {
    'Push': pygame.Rect(50, button_y, BUTTON_WIDTH, BUTTON_HEIGHT),
    'Pop': pygame.Rect(200, button_y, BUTTON_WIDTH, BUTTON_HEIGHT),
    'Peek': pygame.Rect(350, button_y, BUTTON_WIDTH, BUTTON_HEIGHT),
    'Is Empty': pygame.Rect(500, button_y, BUTTON_WIDTH, BUTTON_HEIGHT),
    'Is Full': pygame.Rect(650, button_y, BUTTON_WIDTH, BUTTON_HEIGHT)
}

def draw_grid():
    """Draw a grid on the screen for better visualization."""
    # Starting y position for the grid
    start_y = 100
    end_y = SCREEN_HEIGHT - BUTTON_HEIGHT - 100  # Increased space between grid and buttons

    for x in range(0, SCREEN_WIDTH, GRID_STEP):
        pygame.draw.line(screen, GRID_COLOR, (x, start_y), (x, end_y), 1)
    for y in range(start_y, end_y, GRID_STEP):
        pygame.draw.line(screen, GRID_COLOR, (0, y), (SCREEN_WIDTH, y), 1)

def draw_stack():
    """Draw the stack and buttons on the screen."""
    screen.fill(BACKGROUND_COLOR)

    # Draw grid
    draw_grid()

    # Draw a separator line above buttons
    pygame.draw.line(screen, STACK_BORDER_COLOR,
                    (0, SCREEN_HEIGHT - BUTTON_HEIGHT - 90),
                    (SCREEN_WIDTH, SCREEN_HEIGHT - BUTTON_HEIGHT - 90),
                    2)

    # Draw stack border with rounded corners
    # Calculate stack height to fit within the screen
    stack_spacing = 8  # Reduced spacing between stack items

    # Add padding around items inside the stack border
    stack_padding = 15  # Padding between items and border
    stack_border_height = (ITEM_HEIGHT + stack_spacing) * STACK_SIZE + STACK_BORDER_BOTTOM_HEIGHT + stack_padding * 2

    # Position stack higher on the screen
    stack_start_y = 110  # Moved up slightly
    stack_border_rect = pygame.Rect(SCREEN_WIDTH // 2 - ITEM_WIDTH // 2 - stack_padding, stack_start_y,
                                  ITEM_WIDTH + stack_padding * 2, stack_border_height)
    pygame.draw.rect(screen, STACK_BORDER_COLOR, stack_border_rect, STACK_BORDER_WIDTH, border_radius=10)

    # Draw stack title
    font = pygame.font.Font(None, FONT_SIZE)
    title = font.render("STACK", True, STACK_BORDER_COLOR)
    title_rect = title.get_rect(center=(SCREEN_WIDTH // 2, 90))
    screen.blit(title, title_rect)

    # Draw empty slots first
    stack_spacing = 8  # Reduced spacing between stack items
    small_font = pygame.font.Font(None, INSTRUCTION_FONT_SIZE)

    # Adjust starting position to account for padding
    item_start_y = stack_start_y + stack_padding

    # Draw index numbers on the left side
    for i in range(STACK_SIZE):
        y = item_start_y + (ITEM_HEIGHT + stack_spacing) * i
        index_text = small_font.render(f"{STACK_SIZE - i - 1}", True, INDEX_COLOR)
        screen.blit(index_text, (SCREEN_WIDTH // 2 - ITEM_WIDTH // 2 - 30, y + ITEM_HEIGHT // 2 - 10))

        # Draw empty slots with light color
        if i >= STACK_SIZE - len(stack):
            continue  # Skip drawing empty slots where items will be

        # Draw empty slot
        empty_rect = pygame.Rect(SCREEN_WIDTH // 2 - ITEM_WIDTH // 2, y, ITEM_WIDTH, ITEM_HEIGHT)
        pygame.draw.rect(screen, EMPTY_SLOT_COLOR, empty_rect, border_radius=5)
        pygame.draw.rect(screen, ITEM_BORDER_COLOR, empty_rect, 1, border_radius=5)

    # Draw stack items from bottom to top with improved visuals
    for i, item in enumerate(stack):
        # Calculate position with new spacing and starting position (with padding)
        y = item_start_y + (ITEM_HEIGHT + stack_spacing) * (STACK_SIZE - len(stack) + i)

        # Draw item with rounded corners and gradient effect
        item_rect = pygame.Rect(SCREEN_WIDTH // 2 - ITEM_WIDTH // 2, y, ITEM_WIDTH, ITEM_HEIGHT)
        pygame.draw.rect(screen, ITEM_COLOR, item_rect, border_radius=5)

        # Add a slight gradient effect (lighter at top, darker at bottom)
        lighter_color = (min(ITEM_COLOR[0] + 30, 255), min(ITEM_COLOR[1] + 30, 255), min(ITEM_COLOR[2] + 30, 255))
        gradient_rect = pygame.Rect(SCREEN_WIDTH // 2 - ITEM_WIDTH // 2 + 2, y + 2, ITEM_WIDTH - 4, ITEM_HEIGHT // 2 - 2)
        pygame.draw.rect(screen, lighter_color, gradient_rect, border_radius=3)

        # Draw border
        pygame.draw.rect(screen, ITEM_BORDER_COLOR, item_rect, 2, border_radius=5)

        # Draw item value with better font
        font = pygame.font.Font(None, FONT_SIZE)
        text = font.render(str(item), True, ITEM_TEXT_COLOR)
        text_rect = text.get_rect(center=(SCREEN_WIDTH // 2, y + ITEM_HEIGHT // 2))
        screen.blit(text, text_rect)

    # Draw "TOP" indicator if stack is not empty
    if stack:
        # Calculate top position with new spacing and starting position (with padding)
        top_y = item_start_y + (ITEM_HEIGHT + stack_spacing) * (STACK_SIZE - len(stack))

        # Increased distance from stack border
        arrow_offset = 25  # Increased from 20
        text_offset = 35   # Increased from 25

        # Draw arrow pointing to top element
        arrow_points = [
            (SCREEN_WIDTH // 2 + ITEM_WIDTH // 2 + arrow_offset, top_y + ITEM_HEIGHT // 2),
            (SCREEN_WIDTH // 2 + ITEM_WIDTH // 2 + arrow_offset - 10, top_y + ITEM_HEIGHT // 2 - 10),
            (SCREEN_WIDTH // 2 + ITEM_WIDTH // 2 + arrow_offset - 10, top_y + ITEM_HEIGHT // 2 + 10)
        ]
        pygame.draw.polygon(screen, TOP_INDICATOR_COLOR, arrow_points)

        # Draw TOP text with a small background
        font = pygame.font.Font(None, FONT_SIZE - 5)
        top_text = font.render("TOP", True, TOP_INDICATOR_COLOR)
        text_bg_rect = pygame.Rect(SCREEN_WIDTH // 2 + ITEM_WIDTH // 2 + text_offset, top_y + ITEM_HEIGHT // 2 - 15, 40, 25)
        pygame.draw.rect(screen, (255, 255, 255), text_bg_rect, border_radius=5)
        pygame.draw.rect(screen, TOP_INDICATOR_COLOR, text_bg_rect, 1, border_radius=5)
        screen.blit(top_text, (SCREEN_WIDTH // 2 + ITEM_WIDTH // 2 + text_offset + 5, top_y + ITEM_HEIGHT // 2 - 12))

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

    # Draw button with rounded corners
    pygame.draw.rect(screen, color, rect, border_radius=10)
    pygame.draw.rect(screen, STACK_BORDER_COLOR, rect, 2, border_radius=10)
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

    # Title for instructions
    title_font = pygame.font.Font(None, INSTRUCTION_FONT_SIZE + 5)
    title = title_font.render("Stack Operations:", True, STACK_BORDER_COLOR)
    screen.blit(title, (20, 20))

    instructions = [
        "• Push: Add a new item to the top of the stack",
        "• Pop: Remove the top item from the stack",
        "• Peek: View the top item without removing it",
        "• Is Empty: Check if the stack has no elements",
        "• Is Full: Check if the stack cannot accept more elements"
    ]

    # Add time complexity information
    complexity = [
        "Time Complexity:",
        "Push: O(1)",
        "Pop: O(1)",
        "Peek: O(1)"
    ]

    x_offset = 20
    y_offset = 50

    # Draw main instructions
    for instruction in instructions:
        text_surf = font.render(instruction, True, TEXT_COLOR)
        screen.blit(text_surf, (x_offset, y_offset))
        y_offset += 25

    # Draw time complexity info
    y_offset += 15
    for info in complexity:
        text_surf = font.render(info, True, STACK_BORDER_COLOR)
        screen.blit(text_surf, (x_offset, y_offset))
        y_offset += 25

def display_message(message):
    """Display a message on the screen."""
    global current_message
    current_message = message

def draw_message():
    """Draw the current message on the screen."""
    if current_message:
        font = pygame.font.Font(None, MESSAGE_FONT_SIZE)

        # Determine message color based on content
        message_color = TEXT_COLOR
        if "empty" in current_message or "full" in current_message:
            message_color = ERROR_COLOR
        elif "Pushed" in current_message or "Popped" in current_message:
            message_color = SUCCESS_COLOR

        text_surf = font.render(current_message, True, message_color)
        text_rect = text_surf.get_rect(center=(SCREEN_WIDTH // 2, 50))

        # Draw message box with rounded corners
        message_box = pygame.Rect(20, 10, SCREEN_WIDTH - 40, MESSAGE_BOX_HEIGHT)
        pygame.draw.rect(screen, (255, 255, 255), message_box, border_radius=10)  # Background
        pygame.draw.rect(screen, message_color, message_box, 2, border_radius=10)  # Border
        screen.blit(text_surf, text_rect)

def push():
    """Push an item onto the stack."""
    if len(stack) < STACK_SIZE:
        # Generate a random value between 1 and 99 for more interesting visualization
        value = pygame.time.get_ticks() % 99 + 1
        stack.append(value)  # Push item with random value
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
