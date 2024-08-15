import re
from collections import defaultdict
import sys

def extract_names(input_content):
    lines = input_content.splitlines()
    name_dict = defaultdict(list)
    for line in lines:
        match = re.search(r'\[(.*?)\]', line)
        if match:
            name = match.group(1)
            name_dict[name].append(line)
    
    output = []
    for name, lines in name_dict.items():
        output.append(f'# {name}')
        output.extend(lines)
    
    return '\n'.join(output)

if __name__ == "__main__":
    input_content = sys.stdin.read()
    result = extract_names(input_content)
    print(result)