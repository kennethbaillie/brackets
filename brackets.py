import re
from collections import OrderedDict
import sys

def extract_lines_by_person_with_headers(markdown_text):
    if markdown_text.startswith('---'):
        end_of_yaml = markdown_text.find('\n---', 3)
        if end_of_yaml != -1:
            markdown_text = markdown_text[end_of_yaml + 4:].strip()

    person_lines = OrderedDict()
    lines = markdown_text.split('\n')
    bracket_pattern = re.compile(r'\[([^\]]+)\]')
    header_pattern = re.compile(r'^(#+)\s*(.+)$')
    header_stack = []
    last_header_for_person = {}  # Keep track of the last used header tree for each person
    
    for line in lines:
        header_match = header_pattern.match(line)
        if header_match:
            level = len(header_match.group(1))  # Number of "#" characters
            header_text = header_match.group(2).strip()
            while header_stack and len(header_stack) >= level:
                header_stack.pop()
            header_stack.append(header_text)
        
        brackets = bracket_pattern.findall(line)
        if brackets:
            filtered_brackets = []
            for bracket_content in brackets:
                elements = [elem.strip() for elem in bracket_content.split(',')]
                if not any(elem.lower() in ['x'] for elem in elements) and not any(elem.strip().upper().startswith(('DOI', 'PMID')) for elem in elements):
                    filtered_brackets.append(bracket_content)

            if filtered_brackets:
                for bracket_content in filtered_brackets:
                    names = [name.strip() for name in bracket_content.split(',')]
                    for name in names:
                        if name:
                            if name not in person_lines:
                                person_lines[name] = OrderedDict()
                                last_header_for_person[name] = None  # Initialize last header tree
                            
                            # Construct the current header tree
                            current_header_tree = '\n'.join([f"{'>' * (i+1)} {header}" for i, header in enumerate(header_stack)])
                            
                            # Determine what part of the header tree to add
                            if last_header_for_person[name] is None:
                                header_to_add = current_header_tree
                            else:
                                last_header_parts = last_header_for_person[name].split('\n')
                                current_header_parts = current_header_tree.split('\n')
                                header_to_add = '\n'.join(
                                    current_header_parts[i]
                                    for i in range(len(current_header_parts))
                                    if i >= len(last_header_parts) or current_header_parts[i] != last_header_parts[i]
                                )
                            
                            # Update the last header for the person
                            last_header_for_person[name] = current_header_tree
                            
                            if line.startswith("#"):
                                while line.startswith("#"):
                                    line = line[1:]
                                line = "**"+line.strip()+"**  "
                            if header_to_add not in person_lines[name]:
                                person_lines[name][header_to_add] = []
                            person_lines[name][header_to_add].append(f"\n{line}")
    
    result_lines = []
    for person, headers in person_lines.items():
        result_lines.append(f"### {person}")
        result_lines.append('')  # Add an empty line for formatting
        for header_tree, associated_lines in headers.items():
            result_lines.append(header_tree)
            result_lines.extend(associated_lines)
            result_lines.append('')  # Add an empty line after each section
    
    return '\n'.join(result_lines).strip()

if __name__ == "__main__":
    input_content = sys.stdin.read()
    #with open("baillielab.md") as f:
    #    input_content = f.read()
    result = extract_lines_by_person_with_headers(input_content)
    print(result)


