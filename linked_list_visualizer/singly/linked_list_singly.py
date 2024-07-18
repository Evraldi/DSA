import tkinter as tk
from tkinter import messagebox
import time
from tkinter import filedialog

class Node:
    def __init__(self, data):
        self.data = data
        self.next = None

class LinkedList:
    def __init__(self):
        self.head = None

    def append(self, data):
        new_node = Node(data)
        if self.head is None:
            self.head = new_node
            return
        last = self.head
        while last.next:
            last = last.next
        last.next = new_node

    def insert_at_beginning(self, data):
        new_node = Node(data)
        new_node.next = self.head
        self.head = new_node

    def insert_at_position(self, data, pos):
        if pos == 0:
            self.insert_at_beginning(data)
            return
        new_node = Node(data)
        current = self.head
        for _ in range(pos - 1):
            if current is None:
                return
            current = current.next
        new_node.next = current.next
        current.next = new_node

    def delete_at_position(self, data, pos):
        if pos == 0:
            self.delete_from_beginning()
            return

        temp = self.head
        prev = None
        current_pos = 0

        while temp and current_pos != pos:
            prev = temp
            temp = temp.next
            current_pos += 1
            
        if temp and temp.data == data:
            if prev:
                prev.next = temp.next
            else:
                self.head = temp.next
            temp = None
        else:
            messagebox.showinfo("Delete Node", f"Node with data {data} at position {pos} not found in the list.")

    def delete_from_beginning(self):
        if self.head is None:
            return
        self.head = self.head.next

    def delete_from_end(self):
        if self.head is None:
            return
        if self.head.next is None:
            self.head = None
            return
        second_last = self.head
        while second_last.next.next:
            second_last = second_last.next
        second_last.next = None

    def traverse(self):
        elements = []
        current = self.head
        while current:
            elements.append(current.data)
            current = current.next
        return elements

    def search(self, data):
        current = self.head
        while current:
            if current.data == data:
                return True
            current = current.next
        return False

    def length(self):
        count = 0
        current = self.head
        while current:
            count += 1
            current = current.next
        return count

    def reverse(self):
        prev = None
        current = self.head
        while current:
            next_node = current.next
            current.next = prev
            prev = current
            current = next_node
        self.head = prev

    def merge_sort(self):
        if self.head is None or self.head.next is None:
            return self.head

        def split(head):
            fast = head
            slow = head
            while fast.next and fast.next.next:
                fast = fast.next.next
                slow = slow.next
            middle = slow.next
            slow.next = None
            return head, middle

        def merge(left, right):
            dummy = Node(0)
            tail = dummy
            while left and right:
                if left.data < right.data:
                    tail.next, left = left, left.next
                else:
                    tail.next, right = right, right.next
                tail = tail.next
            tail.next = left or right
            return dummy.next

        def merge_sort_rec(head):
            if head is None or head.next is None:
                return head
            left, right = split(head)
            left = merge_sort_rec(left)
            right = merge_sort_rec(right)
            return merge(left, right)

        self.head = merge_sort_rec(self.head)
        
    def clear_list(self):
        self.head = None

class LinkedListVisualizer(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Singly Linked List Visualizer")
        self.geometry("800x600")
        self.canvas = tk.Canvas(self, width=800, height=350, bg='white')
        self.canvas.pack(pady=20)
        self.linked_list = LinkedList()
        self.node_positions = {}
        self.operations = []
        self.processing = False
        self.create_controls()
        self.update_visualization()

    def create_controls(self):
        control_frame = tk.Frame(self)
        control_frame.pack(pady=20)

        self.entry = tk.Entry(control_frame)
        self.entry.grid(row=0, column=0, padx=5)

        self.position_entry = tk.Entry(control_frame)
        self.position_entry.grid(row=0, column=1, padx=5)
        self.position_entry.insert(0, "Position, start with [0]")

        button_width = 15
        button_height = 1

        insert_begin_button = tk.Button(control_frame, text="Insert at Head", command=self.insert_at_beginning, width=button_width, height=button_height)
        insert_begin_button.grid(row=1, column=0, padx=5)

        insert_end_button = tk.Button(control_frame, text="Insert at Tail", command=self.add_node, width=button_width, height=button_height)
        insert_end_button.grid(row=2, column=0, padx=5)

        insert_pos_button = tk.Button(control_frame, text="Insert at Position", command=self.insert_at_position, width=button_width, height=button_height)
        insert_pos_button.grid(row=3, column=0, padx=5)

        delete_begin_button = tk.Button(control_frame, text="Delete at Head", command=self.delete_from_beginning, width=button_width, height=button_height)
        delete_begin_button.grid(row=1, column=1, padx=5)

        delete_end_button = tk.Button(control_frame, text="Delete at Tail", command=self.delete_from_end, width=button_width, height=button_height)
        delete_end_button.grid(row=2, column=1, padx=5)
        
        delete_button = tk.Button(control_frame, text="Delete at Position", command=self.delete_node, width=button_width, height=button_height)
        delete_button.grid(row=3, column=1, padx=5)

        search_button = tk.Button(control_frame, text="Search Node", command=self.search_node, width=button_width, height=button_height)
        search_button.grid(row=1, column=2, padx=5)

        length_button = tk.Button(control_frame, text="Get Length", command=self.get_length, width=button_width, height=button_height)
        length_button.grid(row=0, column=2, padx=5)

        traverse_button = tk.Button(control_frame, text="Traverse List", command=self.traverse_list, width=button_width, height=button_height)
        traverse_button.grid(row=2, column=2, padx=5)

        reverse_button = tk.Button(control_frame, text="Reverse List", command=self.reverse_list, width=button_width, height=button_height)
        reverse_button.grid(row=3, column=2, padx=5)

        sort_button = tk.Button(control_frame, text="Sort List", command=self.sort_list, width=button_width, height=button_height)
        sort_button.grid(row=0, column=3, padx=5)

        save_button = tk.Button(control_frame, text="Save List", command=self.save_list, width=button_width, height=button_height)
        save_button.grid(row=1, column=3, padx=5)

        load_button = tk.Button(control_frame, text="Load List", command=self.load_list, width=button_width, height=button_height)
        load_button.grid(row=2, column=3, padx=5)
        
        clear_button = tk.Button(control_frame, text="Clear List", command=self.clear_list, width=button_width, height=button_height)
        clear_button.grid(row=3, column=3, padx=5)

    def add_node(self):
        try:
            data = int(self.entry.get())
        except ValueError:
            messagebox.showerror("Invalid input", "Please enter an integer value.")
            return
    
        self.linked_list.append(data)
        self.update_visualization()
        
    '''
    def queue_operation(self, operation):
        self.operations.append(operation)
        if not self.processing:
            self.process_next_operation()

    def process_next_operation(self):
        if self.operations:
            self.processing = True
            operation = self.operations.pop(0)
            operation()
            self.after(500, self.process_next_operation)
        else:
            self.processing = False
    '''
    
    def delete_node(self):
        try:
            data = int(self.entry.get())
            pos = int(self.position_entry.get())
        except ValueError:
            messagebox.showerror("Invalid input", "Please enter a position as an integer.")
            return
        
        if pos < 0 or pos >= self.linked_list.length():
            messagebox.showerror("Invalid Position", "Position is out of range.")
            return
        
        self.linked_list.delete_at_position(data, pos)
        self.update_visualization()

    def insert_at_beginning(self):
        try:
            data = int(self.entry.get())
        except ValueError:
            messagebox.showerror("Invalid input", "Please enter an integer value.")
            return
        self.linked_list.insert_at_beginning(data)
        self.update_visualization()

    def insert_at_position(self):
        try:
            data = int(self.entry.get())
            pos = int(self.position_entry.get())
        except ValueError:
            messagebox.showerror("Invalid input", "Please enter the data and position as integers.")
            return

        if pos < 0 or pos > self.linked_list.length():
            messagebox.showerror("Invalid Position", "Position must be within the range of the list.")
            return

        self.linked_list.insert_at_position(data, pos)
        self.update_visualization()

    def delete_from_beginning(self):
        if self.linked_list.head is None:
            messagebox.showerror("Empty List", "Cannot delete from an empty list.")
            return
        self.linked_list.delete_from_beginning()
        self.update_visualization()

    def delete_from_end(self):
        if self.linked_list.head is None:
            messagebox.showerror("Empty List", "Cannot delete from an empty list.")
            return
        self.linked_list.delete_from_end()
        self.update_visualization()

    def search_node(self):
        try:
            data = int(self.entry.get())
        except ValueError:
            messagebox.showerror("Invalid input", "Please enter an integer value.")
            return
        
        if self.linked_list.search(data):
            messagebox.showinfo("Search Result", f"Node with data {data} found in the list.")
        else:
            messagebox.showinfo("Search Result", f"Node with data {data} not found in the list.")

    def get_length(self):
        length = self.linked_list.length()
        messagebox.showinfo("List Length", f"The length of the list is {length}.")

    def traverse_list(self):
        elements = self.linked_list.traverse()
        messagebox.showinfo("Traversal Result", f"The elements in the list are: {elements}")

    def reverse_list(self):
        self.linked_list.reverse()
        self.update_visualization()

    def sort_list(self):
        self.linked_list.merge_sort()
        self.update_visualization()

    def update_visualization(self):
        self.canvas.delete("all")
        current = self.linked_list.head
        x, y = 50, 200
        self.node_positions.clear()
        while current:
            self.node_positions[current] = (x, y)
            self.canvas.create_oval(x-20, y-20, x+20, y+20, fill="lightblue")
            self.canvas.create_text(x, y, text=str(current.data))
            if current is self.linked_list.head:
                self.canvas.create_text(x-30, y-30, text="Head", anchor=tk.CENTER, font=("Arial", 10, "bold"))
            if current.next is None:
                self.canvas.create_text(x+30, y-30, text="Tail", anchor=tk.CENTER, font=("Arial", 10, "bold"))
            if current.next:
                self.canvas.create_line(x+20, y, x+80-20, y, arrow=tk.LAST)
            x += 80
            current = current.next

    def save_list(self):
        filename = filedialog.asksaveasfilename(defaultextension=".txt",
                                               filetypes=[("Text files", "*.txt"), ("All files", "*.*")],
                                               title="Save Linked List")
        if filename:
            with open(filename, 'w') as file:
                current = self.linked_list.head
                while current:
                    file.write(str(current.data) + '\n')
                    current = current.next
            messagebox.showinfo("Save List", f"List saved to {filename}")

    def load_list(self):
        filename = filedialog.askopenfilename(defaultextension=".txt",
                                              filetypes=[("Text files", "*.txt"), ("All files", "*.*")],
                                              title="Open Linked List")
        if filename:
            self.linked_list = LinkedList()
            with open(filename, 'r') as file:
                for line in file:
                    self.linked_list.append(int(line.strip()))
            self.update_visualization()
            messagebox.showinfo("Load List", f"List loaded from {filename}")
    
    def clear_list(self):
        self.linked_list.clear_list()
        self.update_visualization()

if __name__ == "__main__":
    app = LinkedListVisualizer()
    app.mainloop()