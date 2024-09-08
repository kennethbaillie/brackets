# _extensions/brackets/brackets.py
import re
import sys

def extract_brackets(text):
    # Use regex to find all text in square brackets
    brackets = re.findall(r'\[([^\]]+)\]', text)
    
    # Format as a markdown list
    result = "\n".join(f"- {item}" for item in brackets)
    
    return result

if __name__ == "__main__":
    # Read input from the temporary file passed by Lua
    input_file = sys.argv[1]
    output_file = sys.argv[2]

    with open(input_file, 'r') as f:
        text = f.read()

    # Extract text in brackets and format as markdown list
    output = extract_brackets(text)

    # Write the result to the output file
    with open(output_file, 'w') as f:
        f.write(output)
    sys.stdout.flush()