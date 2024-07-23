class Node:
    def __init__(self, data: int):
        self.data = data
        self.next: 'Node' = None
        self.prev: 'Node' = None

class CircularDoublyLinkedList:
    def __init__(self):
        self.head: Node = None
        self.tail: Node = None

    def is_empty(self) -> bool:
        return self.head is None

    def append(self, data: int) -> None:
        new_node = Node(data)
        if self.is_empty():
            self.head = new_node
            self.tail = new_node
            new_node.next = self.head
            new_node.prev = self.tail
        else:
            new_node.next = self.head
            new_node.prev = self.tail
            self.tail.next = new_node
            self.head.prev = new_node
            self.tail = new_node

    def prepend(self, data: int) -> None:
        new_node = Node(data)
        if self.is_empty():
            self.head = new_node
            self.tail = new_node
            new_node.next = self.head
            new_node.prev = self.tail
        else:
            new_node.next = self.head
            new_node.prev = self.tail
            self.head.prev = new_node
            self.tail.next = new_node
            self.head = new_node

    def delete(self, key: int) -> bool:
        if self.is_empty():
            print("List is empty.")
            return False

        current = self.head
        while True:
            if current.data == key:
                if current == self.head and current == self.tail:
                    self.head = None
                    self.tail = None
                else:
                    if current == self.head:
                        self.head = current.next
                        self.head.prev = self.tail
                        self.tail.next = self.head
                    elif current == self.tail:
                        self.tail = current.prev
                        self.tail.next = self.head
                        self.head.prev = self.tail
                    else:
                        current.prev.next = current.next
                        current.next.prev = current.prev
                return True

            current = current.next
            if current == self.head:
                break
        print("Key not found.")
        return False

    def display(self) -> None:
        if self.is_empty():
            print("List is empty.")
            return
        current = self.head
        result = []
        while True:
            result.append(current.data)
            current = current.next
            if current == self.head:
                break
        print(" <-> ".join(map(str, result)) + " <-> HEAD")

    def search(self, key: int) -> bool:
        if self.is_empty():
            print("List is empty.")
            return False
        current = self.head
        while True:
            if current.data == key:
                return True
            current = current.next
            if current == self.head:
                break
        return False

    def length(self) -> int:
        if self.is_empty():
            return 0
        count = 0
        current = self.head
        while True:
            count += 1
            current = current.next
            if current == self.head:
                break
        return count

    def insert_after(self, prev_data: int, new_data: int) -> None:
        if self.is_empty():
            print("List is empty.")
            return

        current = self.head
        while True:
            if current.data == prev_data:
                new_node = Node(new_data)
                new_node.next = current.next
                new_node.prev = current
                if current.next:
                    current.next.prev = new_node
                current.next = new_node
                if current == self.tail:
                    self.tail = new_node
                return
            current = current.next
            if current == self.head:
                break
        print("Previous data not found.")

    def __iter__(self):
        if self.is_empty():
            return
        current = self.head
        while True:
            yield current.data
            current = current.next
            if current == self.head:
                break

    def __str__(self) -> str:
        if self.is_empty():
            return "List is empty."
        current = self.head
        result = []
        while True:
            result.append(str(current.data))
            current = current.next
            if current == self.head:
                break
        return " <-> ".join(result) + " <-> HEAD"


"""

# Create an instance of CircularDoublyLinkedList
cdll = CircularDoublyLinkedList()

# Append some nodes
cdll.append(10)
cdll.append(20)
cdll.append(30)

# Display the list
cdll.display()  # Output: 10 <-> 20 <-> 30 <-> HEAD

# Prepend a node
cdll.prepend(5)
cdll.display()  # Output: 5 <-> 10 <-> 20 <-> 30 <-> HEAD

# Search for a value
print(cdll.search(20))  # Output: True
print(cdll.search(25))  # Output: False

# Delete a node
cdll.delete(10)
cdll.display()  # Output: 5 <-> 20 <-> 30 <-> HEAD

# Insert a node after a specific value
cdll.insert_after(20, 25)
cdll.display()  # Output: 5 <-> 20 <-> 25 <-> 30 <-> HEAD

# Get the length of the list
print(cdll.length())  # Output: 4

# Iterate over the list
for data in cdll:
    print(data)  # Output: 5 20 25 30

# Print the list using __str__
print(cdll)  # Output: 5 <-> 20 <-> 25 <-> 30 <-> HEAD


"""