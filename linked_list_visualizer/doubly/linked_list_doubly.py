import tkinter as tk
from tkinter import messagebox
from tkinter import filedialog
import time

class DoublyNode:
    def __init__(self, data):
        self.data = data
        self.next = None
        self.prev = None

class DoublyLinkedList:
    def __init__(self):
        self.head = None
        self.tail = None

    def append(self, data):
        new_node = DoublyNode(data)
        if self.head is None:
            self.head = self.tail = new_node
            return
        new_node.prev = self.tail
        self.tail.next = new_node
        self.tail = new_node

    def insert_at_beginning(self, data):
        new_node = DoublyNode(data)
        if self.head is None:
            self.head = self.tail = new_node
            return
        new_node.next = self.head
        self.head.prev = new_node
        self.head = new_node

    def insert_at_position(self, data, pos):
        if pos == 0:
            self.insert_at_beginning(data)
            return
        new_node = DoublyNode(data)
        current = self.head
        for _ in range(pos - 1):
            if current is None:
                return
            current = current.next
        if current is None:
            return
        new_node.next = current.next
        new_node.prev = current
        if current.next:
            current.next.prev = new_node
        current.next = new_node
        if new_node.next is None:
            self.tail = new_node

    def delete(self, data):
        current = self.head
        while current:
            if current.data == data:
                if current.prev:
                    current.prev.next = current.next
                if current.next:
                    current.next.prev = current.prev
                if current == self.head:
                    self.head = current.next
                if current == self.tail:
                    self.tail = current.prev
                return
            current = current.next

    def delete_from_beginning(self):
        if self.head is None:
            return
        if self.head == self.tail:
            self.head = self.tail = None
            return
        self.head = self.head.next
        self.head.prev = None

    def delete_from_end(self):
        if self.tail is None:
            return
        if self.head == self.tail:
            self.head = self.tail = None
            return
        self.tail = self.tail.prev
        self.tail.next = None

    def delete_at_position(self, pos):
        if self.head is None:
            return
        if pos == 0:
            self.delete_from_beginning()
            return
        current = self.head
        for _ in range(pos):
            if current is None:
                return
            current = current.next
        if current is None:
            return
        if current.prev:
            current.prev.next = current.next
        if current.next:
            current.next.prev = current.prev
        if current == self.tail:
            self.tail = current.prev
        if current == self.head:
            self.head = current.next    

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
        current = self.head
        prev = None
        while current:
            next_node = current.next
            current.next = prev
            current.prev = next_node
            prev = current
            current = next_node
        self.head, self.tail = self.tail, self.head

    def merge_sort(self):
        if self.head is None or self.head.next is None:
            return

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
            dummy = DoublyNode(0)
            tail = dummy
            while left and right:
                if left.data < right.data:
                    tail.next = left
                    left.prev = tail
                    left = left.next
                else:
                    tail.next = right
                    right.prev = tail
                    right = right.next
                tail = tail.next
            tail.next = left or right
            if tail.next:
                tail.next.prev = tail
            return dummy.next

        def merge_sort_rec(head):
            if head is None or head.next is None:
                return head
            left, right = split(head)
            left = merge_sort_rec(left)
            right = merge_sort_rec(right)
            return merge(left, right)

        self.head = merge_sort_rec(self.head)
        self.tail = self.head
        while self.tail and self.tail.next:
            self.tail = self.tail.next

class DoublyLinkedListVisualizer(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Doubly Linked List Visualizer")
        self.geometry("800x600")
        self.canvas = tk.Canvas(self, width=800, height=350, bg='white')
        self.canvas.pack(pady=20)
        self.linked_list = DoublyLinkedList()
        self.node_positions = {}
        self.create_controls()
        self.update_visualization()

    def create_controls(self):
        control_frame = tk.Frame(self)
        control_frame.pack(pady=20)

        self.entry = tk.Entry(control_frame)
        self.entry.grid(row=0, column=0, padx=5)

        self.position_entry = tk.Entry(control_frame)
        self.position_entry.grid(row=0, column=1, padx=5)
        self.position_entry.insert(0, "Position [start with 0]")

        button_width = 15  # Define the button width
        button_height = 1  # Define the button height

        add_button = tk.Button(control_frame, text="Add Node", command=self.add_node, width=button_width, height=button_height)
        add_button.grid(row=2, column=0, padx=5)

        delete_button = tk.Button(control_frame, text="Delete Node", command=self.delete_node, width=button_width, height=button_height)
        delete_button.grid(row=0, column=3, padx=5)

        insert_begin_button = tk.Button(control_frame, text="Insert at Beginning", command=self.insert_at_beginning, width=button_width, height=button_height)
        insert_begin_button.grid(row=1, column=0, padx=5)

        insert_pos_button = tk.Button(control_frame, text="Insert at Position", command=self.insert_at_position, width=button_width, height=button_height)
        insert_pos_button.grid(row=3, column=0, padx=5)

        delete_begin_button = tk.Button(control_frame, text="Delete from Beginning", command=self.delete_from_beginning, width=button_width, height=button_height)
        delete_begin_button.grid(row=2, column=1, padx=5)

        delete_end_button = tk.Button(control_frame, text="Delete from End", command=self.delete_from_end, width=button_width, height=button_height)
        delete_end_button.grid(row=1, column=1, padx=5)

        delete_at_position_button = tk.Button(control_frame, text="Delete at Position", command=self.delete_at_position, width=button_width, height=button_height)
        delete_at_position_button.grid(row=3, column=1, padx=5)

        search_button = tk.Button(control_frame, text="Search Node", command=self.search_node, width=button_width, height=button_height)
        search_button.grid(row=0, column=2, padx=5)

        length_button = tk.Button(control_frame, text="Get Length", command=self.get_length, width=button_width, height=button_height)
        length_button.grid(row=3, column=2, padx=5)

        traverse_button = tk.Button(control_frame, text="Traverse List", command=self.traverse_list, width=button_width, height=button_height)
        traverse_button.grid(row=1, column=2, padx=5)

        reverse_button = tk.Button(control_frame, text="Reverse List", command=self.reverse_list, width=button_width, height=button_height)
        reverse_button.grid(row=2, column=2, padx=5)

        sort_button = tk.Button(control_frame, text="Sort List", command=self.sort_list, width=button_width, height=button_height)
        sort_button.grid(row=1, column=3, padx=5)

        save_button = tk.Button(control_frame, text="Save List", command=self.save_list, width=button_width, height=button_height)
        save_button.grid(row=2, column=3, padx=5)

        load_button = tk.Button(control_frame, text="Load List", command=self.load_list, width=button_width, height=button_height)
        load_button.grid(row=3, column=3, padx=5)

    def add_node(self):
        try:
            data = int(self.entry.get())
        except ValueError:
            messagebox.showerror("Invalid input", "Please enter an integer value.")
            return
        self.linked_list.append(data)
        self.update_visualization()

    def delete_node(self):
        try:
            data = int(self.entry.get())
        except ValueError:
            messagebox.showerror("Invalid input", "Please enter an integer value.")
            return
        self.linked_list.delete(data)
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
        self.linked_list.insert_at_position(data, pos)
        self.update_visualization()

    def delete_from_beginning(self):
        self.linked_list.delete_from_beginning()
        self.update_visualization()

    def delete_from_end(self):
        self.linked_list.delete_from_end()
        self.update_visualization()

    def delete_at_position(self):
        try:
            pos = int(self.position_entry.get())
        except ValueError:
            messagebox.showerror("Invalid input", "Please enter a valid integer position.")
            return
        if pos < 0:
            messagebox.showerror("Invalid position", "Position must be a non-negative integer.")
            return
        self.linked_list.delete_at_position(pos)
        self.update_visualization()

    def search_node(self):
        try:
            data = int(self.entry.get())
        except ValueError:
            messagebox.showerror("Invalid input", "Please enter an integer value.")
            return
        current = self.linked_list.head
        found = False
        while current:
            x, y = self.node_positions[current]
            if current.data == data:
                self.canvas.create_oval(x-20, y-20, x+20, y+20, fill="green")
                self.canvas.create_text(x, y, text=str(current.data))
                self.update()
                time.sleep(1)
                found = True
            current = current.next
        if not found:
            messagebox.showinfo("Search Result", f"Node with data {data} not found in the list.")
        self.update_visualization()

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
            if current.prev:
                self.canvas.create_line(x-80, y, x-20, y, arrow=tk.BOTH)
            if current.next:
                self.canvas.create_line(x+20, y, x+80, y, arrow=tk.BOTH)
            x += 80
            current = current.next
        self.animate_linked_list()

    def animate_linked_list(self):
        for node, (x, y) in self.node_positions.items():
            self.canvas.create_oval(x-20, y-20, x+20, y+20, fill="yellow")
            self.canvas.create_text(x, y, text=str(node.data))
            self.update()
            time.sleep(0.5)
            self.canvas.create_oval(x-20, y-20, x+20, y+20, fill="lightblue")
            self.canvas.create_text(x, y, text=str(node.data))

    def save_list(self):
        filename = filedialog.asksaveasfilename(defaultextension=".txt", filetypes=[("Text files", "*.txt")])
        if filename:
            with open(filename, 'w') as file:
                current = self.linked_list.head
                while current:
                    file.write(str(current.data) + '\n')
                    current = current.next
            messagebox.showinfo("Save List", f"List saved to {filename}")

    def load_list(self):
        filename = filedialog.askopenfilename(filetypes=[("Text files", "*.txt")])
        if filename:
            self.linked_list = DoublyLinkedList()
            with open(filename, 'r') as file:
                for line in file:
                    self.linked_list.append(int(line.strip()))
            self.update_visualization()
            messagebox.showinfo("Load List", f"List loaded from {filename}")

if __name__ == "__main__":
    app = DoublyLinkedListVisualizer()
    app.mainloop()