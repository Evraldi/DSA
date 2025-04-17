import pygame
import sys
from collections import deque
import random
import time

# Initialize Pygame
pygame.init()

# Constants
SCREEN_WIDTH = 1200
SCREEN_HEIGHT = 800
FPS = 60

# Colors
BACKGROUND_COLOR = (240, 240, 250)  # Light blue-grey
QUEUE_BORDER_COLOR = (70, 130, 180)  # Steel blue
ITEM_COLOR = (135, 206, 235)  # Sky blue
ITEM_HOVER_COLOR = (100, 149, 237)  # Cornflower blue
TEXT_COLOR = (25, 25, 112)  # Midnight blue
BUTTON_COLOR = (70, 130, 180)  # Steel blue
BUTTON_HOVER_COLOR = (100, 149, 237)  # Cornflower blue
BUTTON_TEXT_COLOR = (255, 255, 255)  # White
ERROR_COLOR = (220, 20, 60)  # Crimson
SUCCESS_COLOR = (46, 139, 87)  # Sea green

# Queue visualization settings
ITEM_WIDTH = 60
ITEM_HEIGHT = 60
ITEM_SPACING = 10
QUEUE_CAPACITY = 10
ANIMATION_SPEED = 5

class QueueVisualizer:
    def __init__(self):
        self.screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
        pygame.display.set_caption("Queue Visualizer")
        self.clock = pygame.time.Clock()
        
        # Initialize queue
        self.queue = deque(maxlen=QUEUE_CAPACITY)
        self.font = pygame.font.Font(None, 36)
        self.small_font = pygame.font.Font(None, 24)
        
        # Animation states
        self.animating = False
        self.animation_item = None
        self.animation_start_pos = None
        self.animation_end_pos = None
        self.animation_progress = 0
        
        # Message system
        self.message = ""
        self.message_color = TEXT_COLOR
        self.message_timer = 0
        
        # Buttons
        self.buttons = self.create_buttons()
        
        # Statistics
        self.operations_count = 0
        self.start_time = time.time()

    def create_buttons(self):
        buttons = {
            'enqueue': {'rect': pygame.Rect(50, 650, 120, 40), 'text': 'Enqueue', 'action': self.enqueue},
            'dequeue': {'rect': pygame.Rect(190, 650, 120, 40), 'text': 'Dequeue', 'action': self.dequeue},
            'peek': {'rect': pygame.Rect(330, 650, 120, 40), 'text': 'Peek', 'action': self.peek},
            'clear': {'rect': pygame.Rect(470, 650, 120, 40), 'text': 'Clear', 'action': self.clear},
            'random': {'rect': pygame.Rect(610, 650, 120, 40), 'text': 'Random', 'action': self.random_operations}
        }
        return buttons

    def show_message(self, text, color=TEXT_COLOR):
        self.message = text
        self.message_color = color
        self.message_timer = 2 * FPS  # Display for 2 seconds

    def enqueue(self):
        if len(self.queue) >= QUEUE_CAPACITY:
            self.show_message("Queue is full!", ERROR_COLOR)
            return
        
        value = random.randint(1, 99)
        start_pos = (SCREEN_WIDTH + ITEM_WIDTH, 300)
        end_pos = self.get_item_position(len(self.queue))
        
        self.animation_item = value
        self.animation_start_pos = start_pos
        self.animation_end_pos = end_pos
        self.animating = True
        self.animation_progress = 0
        
        self.queue.append(value)
        self.operations_count += 1
        self.show_message(f"Enqueued: {value}", SUCCESS_COLOR)

    def dequeue(self):
        if not self.queue:
            self.show_message("Queue is empty!", ERROR_COLOR)
            return
        
        value = self.queue.popleft()
        self.operations_count += 1
        self.show_message(f"Dequeued: {value}", SUCCESS_COLOR)

    def peek(self):
        if not self.queue:
            self.show_message("Queue is empty!", ERROR_COLOR)
            return
        
        value = self.queue[0]
        self.show_message(f"Front element: {value}")

    def clear(self):
        self.queue.clear()
        self.show_message("Queue cleared", SUCCESS_COLOR)

    def random_operations(self):
        operations = ['enqueue', 'dequeue']
        operation = random.choice(operations)
        if operation == 'enqueue':
            self.enqueue()
        else:
            self.dequeue()

    def get_item_position(self, index):
        x = 50 + index * (ITEM_WIDTH + ITEM_SPACING)
        y = 300
        return (x, y)

    def draw_queue(self):
        # Draw queue container
        container_rect = pygame.Rect(40, 250, 
                                   (ITEM_WIDTH + ITEM_SPACING) * QUEUE_CAPACITY + ITEM_SPACING,
                                   ITEM_HEIGHT + 20)
        pygame.draw.rect(self.screen, QUEUE_BORDER_COLOR, container_rect, 3, border_radius=10)
        
        # Draw "Front" and "Rear" labels
        if self.queue:
            front_pos = self.get_item_position(0)
            rear_pos = self.get_item_position(len(self.queue) - 1)
            
            # Jika hanya ada 1 elemen (front dan rear sama)
            if len(self.queue) == 1:
                # Front label di atas
                front_text = self.font.render("Front", True, TEXT_COLOR)
                self.screen.blit(front_text, (front_pos[0], front_pos[1] - 60))
                
                # Rear label di bawah
                rear_text = self.font.render("Rear", True, TEXT_COLOR)
                self.screen.blit(rear_text, (rear_pos[0], rear_pos[1] + ITEM_HEIGHT + 10))
            else:
                # Tampilan normal untuk multiple elements
                front_text = self.font.render("Front", True, TEXT_COLOR)
                rear_text = self.font.render("Rear", True, TEXT_COLOR)
                self.screen.blit(front_text, (front_pos[0], front_pos[1] - 40))
                self.screen.blit(rear_text, (rear_pos[0], rear_pos[1] - 40))

        # Draw queue items
        for i, value in enumerate(self.queue):
            pos = self.get_item_position(i)
            self.draw_item(pos[0], pos[1], value)

    def draw_item(self, x, y, value):
        # Draw item box
        item_rect = pygame.Rect(x, y, ITEM_WIDTH, ITEM_HEIGHT)
        pygame.draw.rect(self.screen, ITEM_COLOR, item_rect, border_radius=5)
        pygame.draw.rect(self.screen, QUEUE_BORDER_COLOR, item_rect, 2, border_radius=5)
        
        # Draw value
        value_text = self.font.render(str(value), True, TEXT_COLOR)
        text_rect = value_text.get_rect(center=(x + ITEM_WIDTH // 2, y + ITEM_HEIGHT // 2))
        self.screen.blit(value_text, text_rect)

    def draw_buttons(self):
        mouse_pos = pygame.mouse.get_pos()
        
        for button_info in self.buttons.values():
            rect = button_info['rect']
            color = BUTTON_HOVER_COLOR if rect.collidepoint(mouse_pos) else BUTTON_COLOR
            
            # Draw button
            pygame.draw.rect(self.screen, color, rect, border_radius=5)
            pygame.draw.rect(self.screen, QUEUE_BORDER_COLOR, rect, 2, border_radius=5)
            
            # Draw text
            text = self.font.render(button_info['text'], True, BUTTON_TEXT_COLOR)
            text_rect = text.get_rect(center=rect.center)
            self.screen.blit(text, text_rect)

    def draw_statistics(self):
        stats_text = [
            f"Operations: {self.operations_count}",
            f"Queue Size: {len(self.queue)}/{QUEUE_CAPACITY}",
            f"Time: {int(time.time() - self.start_time)}s"
        ]
        
        y = 50
        for text in stats_text:
            surface = self.small_font.render(text, True, TEXT_COLOR)
            self.screen.blit(surface, (50, y))
            y += 30

    def run(self):
        running = True
        while running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
                elif event.type == pygame.MOUSEBUTTONDOWN:
                    mouse_pos = pygame.mouse.get_pos()
                    for button_info in self.buttons.values():
                        if button_info['rect'].collidepoint(mouse_pos):
                            button_info['action']()

            # Clear screen
            self.screen.fill(BACKGROUND_COLOR)

            # Draw queue and UI elements
            self.draw_queue()
            self.draw_buttons()
            self.draw_statistics()

            # Draw message if active
            if self.message_timer > 0:
                message_surface = self.font.render(self.message, True, self.message_color)
                message_rect = message_surface.get_rect(center=(SCREEN_WIDTH // 2, 200))
                self.screen.blit(message_surface, message_rect)
                self.message_timer -= 1

            # Update display
            pygame.display.flip()
            self.clock.tick(FPS)

        pygame.quit()
        sys.exit()

if __name__ == "__main__":
    visualizer = QueueVisualizer()
    visualizer.run()
