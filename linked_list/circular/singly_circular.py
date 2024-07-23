class Node:
    def __init__(self, data: int):
        self.data = data
        self.next: 'Node' = None

class CircularSinglyLinkedList:
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
        else:
            self.tail.next = new_node
            new_node.next = self.head
            self.tail = new_node

    def prepend(self, data: int) -> None:
        new_node = Node(data)
        if self.is_empty():
            self.head = new_node
            self.tail = new_node
            new_node.next = self.head
        else:
            new_node.next = self.head
            self.head = new_node
            self.tail.next = new_node

    def delete(self, key: int) -> bool:
        if self.is_empty():
            print("List is empty.")
            return False

        current = self.head
        previous = None

        while True:
            if current.data == key:
                if previous:
                    previous.next = current.next
                    if current == self.tail:
                        self.tail = previous
                else:
                    if self.head == self.tail:
                        self.head = None
                        self.tail = None
                    else:
                        temp = self.head
                        while temp.next != self.head:
                            temp = temp.next
                        temp.next = current.next
                        self.head = current.next
                        self.tail.next = self.head
                return True

            previous = current
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
        print(" -> ".join(map(str, result)) + " -> HEAD")

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
        return " -> ".join(result) + " -> HEAD"
