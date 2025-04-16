import tkinter as tk
from tkinter import ttk
from tkinter import messagebox
from tkinter import filedialog
import time
from circular_singly.circular_singly import CircularSinglyLinkedList
from circular_doubly.circular_doubly import CircularDoublyLinkedList

class CircularLinkedListVisualizer(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Circular Linked List Visualizer")
        self.geometry("1200x800")
        
        # Create tabs for different types of lists
        self.tab_control = ttk.Notebook(self)
        
        # Create frames for each tab
        self.singly_frame = tk.Frame(self.tab_control)
        self.doubly_frame = tk.Frame(self.tab_control)
        
        self.tab_control.add(self.singly_frame, text='Circular Singly Linked List')
        self.tab_control.add(self.doubly_frame, text='Circular Doubly Linked List')
        self.tab_control.pack(expand=1, fill="both")
        
        # Initialize both types of lists
        self.singly_list = CircularSinglyLinkedList()
        self.doubly_list = CircularDoublyLinkedList()
        
        # Create separate canvases for each list type
        self.singly_canvas = tk.Canvas(self.singly_frame, width=1100, height=400, bg='white')
        self.doubly_canvas = tk.Canvas(self.doubly_frame, width=1100, height=400, bg='white')
        
        self.singly_canvas.pack(pady=20)
        self.doubly_canvas.pack(pady=20)
        
        self.create_controls()
        self.update_visualization()

    def create_controls(self):
        # Controls for Singly Linked List
        singly_control_frame = tk.Frame(self.singly_frame)
        singly_control_frame.pack(pady=20)
        
        # Create labeled frames for different operation types
        basic_ops_frame = ttk.LabelFrame(singly_control_frame, text="Basic Operations")
        basic_ops_frame.grid(row=0, column=0, padx=10, pady=5)
        
        insert_ops_frame = ttk.LabelFrame(singly_control_frame, text="Insert Operations")
        insert_ops_frame.grid(row=0, column=1, padx=10, pady=5)
        
        delete_ops_frame = ttk.LabelFrame(singly_control_frame, text="Delete Operations")
        delete_ops_frame.grid(row=0, column=2, padx=10, pady=5)
        
        utility_ops_frame = ttk.LabelFrame(singly_control_frame, text="Utility Operations")
        utility_ops_frame.grid(row=0, column=3, padx=10, pady=5)
        
        # Entry fields
        entry_frame = tk.Frame(basic_ops_frame)
        entry_frame.pack(pady=5)
        
        tk.Label(entry_frame, text="Value:").grid(row=0, column=0)
        self.singly_entry = tk.Entry(entry_frame, width=10)
        self.singly_entry.grid(row=0, column=1, padx=5)
        
        tk.Label(entry_frame, text="Position:").grid(row=0, column=2)
        self.singly_position_entry = tk.Entry(entry_frame, width=10)
        self.singly_position_entry.grid(row=0, column=3, padx=5)
        
        button_width = 15
        button_height = 1
        
        # Basic Operations
        tk.Button(basic_ops_frame, text="Append", 
                 command=lambda: self.add_node('singly', 'append'),
                 width=button_width).pack(pady=2)
        tk.Button(basic_ops_frame, text="Prepend", 
                 command=lambda: self.add_node('singly', 'prepend'),
                 width=button_width).pack(pady=2)
        
        # Insert Operations
        tk.Button(insert_ops_frame, text="Insert After Value", 
                 command=lambda: self.insert_after_value('singly'),
                 width=button_width).pack(pady=2)
        tk.Button(insert_ops_frame, text="Insert At Position", 
                 command=lambda: self.insert_at_position('singly'),
                 width=button_width).pack(pady=2)
        
        # Delete Operations
        tk.Button(delete_ops_frame, text="Delete Value", 
                 command=lambda: self.delete_node('singly'),
                 width=button_width).pack(pady=2)
        tk.Button(delete_ops_frame, text="Delete At Position", 
                 command=lambda: self.delete_at_position('singly'),
                 width=button_width).pack(pady=2)
        tk.Button(delete_ops_frame, text="Delete First", 
                 command=lambda: self.delete_first('singly'),
                 width=button_width).pack(pady=2)
        tk.Button(delete_ops_frame, text="Delete Last", 
                 command=lambda: self.delete_last('singly'),
                 width=button_width).pack(pady=2)
        
        # Utility Operations
        tk.Button(utility_ops_frame, text="Search", 
                 command=lambda: self.search_node('singly'),
                 width=button_width).pack(pady=2)
        tk.Button(utility_ops_frame, text="Get Length", 
                 command=lambda: self.show_length('singly'),
                 width=button_width).pack(pady=2)
        tk.Button(utility_ops_frame, text="Clear List", 
                 command=lambda: self.clear_list('singly'),
                 width=button_width).pack(pady=2)
        tk.Button(utility_ops_frame, text="Display List", 
                 command=lambda: self.display_list('singly'),
                 width=button_width).pack(pady=2)

        # Controls for Doubly Linked List
        doubly_control_frame = tk.Frame(self.doubly_frame)
        doubly_control_frame.pack(pady=20)
        
        # Create labeled frames for different operation types (doubly)
        doubly_basic_ops_frame = ttk.LabelFrame(doubly_control_frame, text="Basic Operations")
        doubly_basic_ops_frame.grid(row=0, column=0, padx=10, pady=5)
        
        doubly_insert_ops_frame = ttk.LabelFrame(doubly_control_frame, text="Insert Operations")
        doubly_insert_ops_frame.grid(row=0, column=1, padx=10, pady=5)
        
        doubly_delete_ops_frame = ttk.LabelFrame(doubly_control_frame, text="Delete Operations")
        doubly_delete_ops_frame.grid(row=0, column=2, padx=10, pady=5)
        
        doubly_utility_ops_frame = ttk.LabelFrame(doubly_control_frame, text="Utility Operations")
        doubly_utility_ops_frame.grid(row=0, column=3, padx=10, pady=5)
        
        # Entry fields for doubly linked list
        doubly_entry_frame = tk.Frame(doubly_basic_ops_frame)
        doubly_entry_frame.pack(pady=5)
        
        tk.Label(doubly_entry_frame, text="Value:").grid(row=0, column=0)
        self.doubly_entry = tk.Entry(doubly_entry_frame, width=10)
        self.doubly_entry.grid(row=0, column=1, padx=5)
        
        tk.Label(doubly_entry_frame, text="Position:").grid(row=0, column=2)
        self.doubly_position_entry = tk.Entry(doubly_entry_frame, width=10)
        self.doubly_position_entry.grid(row=0, column=3, padx=5)
        
        button_width = 15
        
        # Basic Operations (Doubly)
        tk.Button(doubly_basic_ops_frame, text="Append", 
                 command=lambda: self.add_node('doubly', 'append'),
                 width=button_width).pack(pady=2)
        tk.Button(doubly_basic_ops_frame, text="Prepend", 
                 command=lambda: self.add_node('doubly', 'prepend'),
                 width=button_width).pack(pady=2)
        
        # Insert Operations (Doubly)
        tk.Button(doubly_insert_ops_frame, text="Insert After Value", 
                 command=lambda: self.insert_after_value('doubly'),
                 width=button_width).pack(pady=2)
        tk.Button(doubly_insert_ops_frame, text="Insert At Position", 
                 command=lambda: self.insert_at_position('doubly'),
                 width=button_width).pack(pady=2)
        
        # Delete Operations (Doubly)
        tk.Button(doubly_delete_ops_frame, text="Delete Value", 
                 command=lambda: self.delete_node('doubly'),
                 width=button_width).pack(pady=2)
        tk.Button(doubly_delete_ops_frame, text="Delete At Position", 
                 command=lambda: self.delete_at_position('doubly'),
                 width=button_width).pack(pady=2)
        tk.Button(doubly_delete_ops_frame, text="Delete First", 
                 command=lambda: self.delete_first('doubly'),
                 width=button_width).pack(pady=2)
        tk.Button(doubly_delete_ops_frame, text="Delete Last", 
                 command=lambda: self.delete_last('doubly'),
                 width=button_width).pack(pady=2)
        
        # Utility Operations (Doubly)
        tk.Button(doubly_utility_ops_frame, text="Search", 
                 command=lambda: self.search_node('doubly'),
                 width=button_width).pack(pady=2)
        tk.Button(doubly_utility_ops_frame, text="Get Length", 
                 command=lambda: self.show_length('doubly'),
                 width=button_width).pack(pady=2)
        tk.Button(doubly_utility_ops_frame, text="Clear List", 
                 command=lambda: self.clear_list('doubly'),
                 width=button_width).pack(pady=2)
        tk.Button(doubly_utility_ops_frame, text="Display List", 
                 command=lambda: self.display_list('doubly'),
                 width=button_width).pack(pady=2)

    def get_value_and_position(self, list_type='singly'):
        try:
            value = int(self.singly_entry.get() if list_type == 'singly' else self.doubly_entry.get())
            position = int(self.singly_position_entry.get() if list_type == 'singly' else self.doubly_position_entry.get())
            return value, position
        except ValueError:
            messagebox.showerror("Error", "Please enter valid integers")
            return None, None

    def insert_after_value(self, list_type):
        try:
            prev_value = int(self.singly_position_entry.get() if list_type == 'singly' else self.doubly_position_entry.get())
            new_value = int(self.singly_entry.get() if list_type == 'singly' else self.doubly_entry.get())
            if list_type == 'singly':
                self.singly_list.insert_after(prev_value, new_value)
            else:
                self.doubly_list.insert_after(prev_value, new_value)
            self.update_visualization()
        except ValueError:
            messagebox.showerror("Error", "Please enter valid integers")

    def insert_at_position(self, list_type):
        value, position = self.get_value_and_position(list_type)
        if value is not None and position is not None:
            if list_type == 'singly':
                # Add implementation for insert at position
                current = self.singly_list.head
                if position == 0:
                    self.singly_list.prepend(value)
                else:
                    count = 0
                    while count < position - 1 and current is not None:
                        current = current.next
                        count += 1
                    if current is not None:
                        self.singly_list.insert_after(current.data, value)
                self.update_visualization()

    def delete_first(self, list_type):
        if list_type == 'singly':
            if not self.singly_list.is_empty():
                self.singly_list.delete(self.singly_list.head.data)
                self.update_visualization()
            else:
                messagebox.showinfo("Info", "List is empty")

    def delete_last(self, list_type):
        if list_type == 'singly':
            if not self.singly_list.is_empty():
                self.singly_list.delete(self.singly_list.tail.data)
                self.update_visualization()
            else:
                messagebox.showinfo("Info", "List is empty")

    def delete_at_position(self, list_type):
        try:
            position = int(self.singly_position_entry.get())
            if list_type == 'singly':
                current = self.singly_list.head
                if position == 0:
                    self.delete_first(list_type)
                else:
                    count = 0
                    while count < position and current is not None:
                        current = current.next
                        count += 1
                    if current is not None:
                        self.singly_list.delete(current.data)
                self.update_visualization()
        except ValueError:
            messagebox.showerror("Error", "Please enter a valid position")

    def show_length(self, list_type):
        length = 0
        if list_type == 'singly':
            length = self.singly_list.length()
        else:
            length = self.doubly_list.length()
        messagebox.showinfo("List Length", f"The {list_type} list contains {length} nodes")

    def clear_list(self, list_type):
        if list_type == 'singly':
            while not self.singly_list.is_empty():
                self.singly_list.delete(self.singly_list.head.data)
        else:
            while not self.doubly_list.is_empty():
                self.doubly_list.delete(self.doubly_list.head.data)
        self.update_visualization()

    def display_list(self, list_type):
        elements = []
        if list_type == 'singly':
            if not self.singly_list.is_empty():
                current = self.singly_list.head
                while True:
                    elements.append(str(current.data))
                    current = current.next
                    if current == self.singly_list.head:
                        break
        else:
            if not self.doubly_list.is_empty():
                current = self.doubly_list.head
                while True:
                    elements.append(str(current.data))
                    current = current.next
                    if current == self.doubly_list.head:
                        break
        
        separator = " -> " if list_type == 'singly' else " <-> "
        messagebox.showinfo("List Contents", 
                          separator.join(elements) + " -> HEAD" if elements else "Empty List")

    def add_node(self, list_type, operation):
        try:
            value = int(self.singly_entry.get() if list_type == 'singly' else self.doubly_entry.get())
            if operation == 'append':
                if list_type == 'singly':
                    self.singly_list.append(value)
                else:
                    self.doubly_list.append(value)
            else:  # prepend
                if list_type == 'singly':
                    self.singly_list.prepend(value)
                else:
                    self.doubly_list.prepend(value)
            self.update_visualization()
        except ValueError:
            messagebox.showerror("Error", "Please enter a valid integer")

    def delete_node(self, list_type):
        try:
            value = int(self.singly_entry.get() if list_type == 'singly' else self.doubly_entry.get())
            if list_type == 'singly':
                self.singly_list.delete(value)
            else:
                self.doubly_list.delete(value)
            self.update_visualization()
        except ValueError:
            messagebox.showerror("Error", "Please enter a valid integer")

    def search_node(self, list_type):
        try:
            value = int(self.singly_entry.get() if list_type == 'singly' else self.doubly_entry.get())
            found = False
            if list_type == 'singly':
                found = self.singly_list.search(value)
            else:
                found = self.doubly_list.search(value)
            messagebox.showinfo("Search Result", 
                              f"Value {value} {'found' if found else 'not found'} in the list")
        except ValueError:
            messagebox.showerror("Error", "Please enter a valid integer")

    def update_visualization(self):
        # Clear both canvases
        self.singly_canvas.delete("all")
        self.doubly_canvas.delete("all")

        # Update Singly Linked List visualization
        if not self.singly_list.is_empty():
            x, y = 50, 200
            current = self.singly_list.head
            first_node = current
            first_x = x

            while True:
                # Draw node
                self.singly_canvas.create_oval(x-20, y-20, x+20, y+20, fill="lightblue")
                self.singly_canvas.create_text(x, y, text=str(current.data))
                
                if current == self.singly_list.head:
                    self.singly_canvas.create_text(x, y-30, text="Head")
                if current == self.singly_list.tail:
                    self.singly_canvas.create_text(x, y+30, text="Tail")
                
                current = current.next
                if current != first_node:
                    # Draw forward arrow
                    self.singly_canvas.create_line(x+20, y, x+60, y, arrow=tk.LAST)
                    x += 80
                else:
                    # Draw circular arrow back to first node
                    self.singly_canvas.create_line(x+20, y, x+40, y, x+40, y-40, 
                                                 first_x-40, y-40, first_x-40, y, 
                                                 first_x-20, y, smooth=True, arrow=tk.LAST)
                    break

        # Update Doubly Linked List visualization
        if not self.doubly_list.is_empty():
            x, y = 50, 200
            current = self.doubly_list.head
            first_node = current
            first_x = x

            while True:
                # Draw node
                self.doubly_canvas.create_oval(x-20, y-20, x+20, y+20, fill="lightgreen")
                self.doubly_canvas.create_text(x, y, text=str(current.data))
                
                if current == self.doubly_list.head:
                    self.doubly_canvas.create_text(x, y-30, text="Head")
                if current == self.doubly_list.tail:
                    self.doubly_canvas.create_text(x, y+30, text="Tail")
                
                current = current.next
                if current != first_node:
                    # Draw bidirectional arrow
                    self.doubly_canvas.create_line(x+20, y, x+60, y, arrow=tk.BOTH)
                    x += 80
                else:
                    # Draw circular bidirectional arrows
                    self.doubly_canvas.create_line(x+20, y, x+40, y, x+40, y-40, 
                                                 first_x-40, y-40, first_x-40, y, 
                                                 first_x-20, y, smooth=True, arrow=tk.BOTH)
                    break

if __name__ == "__main__":
    app = CircularLinkedListVisualizer()
    app.mainloop()


