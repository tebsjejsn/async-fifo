import random
from itertools import chain

def generate_inputs(filename):
    chars = []
    ascii_vals = []

    for ascii_val in chain(range(48, 58), range(65, 71)):
        ascii_vals.append(ascii_val)

    with open(filename, "w") as f:
        for number in range(2000):
            for digit in range(8):
                chars.append(chr(random.choice(ascii_vals)))
            
            f.write(f"{"".join(chars)}\n")
            chars.clear();

if __name__ == "__main__":
    generate_inputs("data/wr_data.txt")