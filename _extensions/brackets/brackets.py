import re
import sys
from typing import List, Dict, Any

exclude_names = {"x", "X", "[ ]"}

def should_exclude(name: str) -> bool:
    return name in exclude_names

def should_ignore(bracketed_content: str) -> bool:
    for name in re.findall(r'[^,]+', bracketed_content):
        name = name.strip()
        if name.startswith('DOI') or name.startswith('PMID'):
            return True
    return False

def process_document(text: str) -> Dict[str, List[Dict[str, Any]]]:
    name_dict: Dict[str, List[Dict[str, Any]]] = {}
    header_stack: List[Dict[str, int]] = []
    order_counter = 0

    lines = text.split('\n')
    for line in lines:
        order_counter += 1
        header_match = re.match(r'^(#+)\s+(.+)$', line)
        if header_match:
            level = len(header_match.group(1))
            content = header_match.group(2)
            while header_stack and header_stack[-1]['level'] >= level:
                header_stack.pop()
            header_stack.append({"level": level, "content": content})
        
        for bracketed_content in re.findall(r'\[(.*?)\]', line):
            if should_ignore(bracketed_content):
                continue
            for name in re.findall(r'[^,]+', bracketed_content):
                name = name.strip()
                if should_exclude(name):
                    continue
                if name not in name_dict:
                    name_dict[name] = []
                entry = {
                    "headers": [h['content'] for h in header_stack],
                    "content": line,
                    "order": order_counter
                }
                name_dict[name].append(entry)

    return name_dict

def generate_output(name_dict: Dict[str, List[Dict[str, Any]]]) -> str:
    output = []
    sorted_names = sorted(name_dict.keys())
    prev_header_stack = {}

    for name in sorted_names:
        if name not in prev_header_stack:
            prev_header_stack[name] = []
        output.append(f"### {name}")
        entries = sorted(name_dict[name], key=lambda x: x["order"])
        for entry in entries:
            stored_header_stack = entry["headers"]
            h_index = 0
            for j, header in enumerate(entry["headers"]):
                if j < len(prev_header_stack[name]) and prev_header_stack[name][j] == header:
                    h_index = j + 1
                else:
                    break
            prev_header_stack[name] = stored_header_stack
            for i in range(h_index, len(entry["headers"])):
                header = entry["headers"][i]
                output.append(">" * (i + 1) + " " + header)
            if entry["content"]:
                output.append(entry["content"])
        output.append("")  # Add an empty line between sections

    return "\n".join(output)

if __name__ == "__main__":
    input_text = sys.stdin.read()
    name_dict = process_document(input_text)
    output = generate_output(name_dict)
    
    # Write directly to stdout instead of creating a separate file
    sys.stdout.write(output)
    sys.stdout.flush()