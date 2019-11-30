class Process:
    def __init__(self, pid):
        self.id = pid
        self.props = {}
        with open(f'/proc/{pid}/status', 'r') as f:
            for line in f:
                split_pos = line.index(':')
                key = line[0:split_pos].strip()
                split_pos += 1
                value = line[split_pos:].strip()
                self.props[key] = value

    def get(self, key):
        return self.props[key]

    def name(self):
        return self.get('Name')
