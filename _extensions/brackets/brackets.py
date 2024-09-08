import re
import json
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

order_counter = 0

def process_line(line: str, header_stack: List[Dict[str, Any]], name_dict: Dict[str, List[Dict[str, Any]]], is_header: bool) -> None:
    global order_counter
    order_counter += 1
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
                "headers": header_stack.copy(),
                "content": "" if is_header else line,
                "order": order_counter
            }
            name_dict[name].append(entry)

def process_document(blocks: List[Dict[str, Any]]) -> Dict[str, List[Dict[str, Any]]]:
    name_dict: Dict[str, List[Dict[str, Any]]] = {}
    header_stack: List[Dict[str, Any]] = []

    for block in blocks:
        if block['t'] == 'Header':
            level = block['level']
            content = ''.join(block['c'][2])
            while header_stack and header_stack[-1]['level'] >= level:
                header_stack.pop()
            header_stack.append({"level": level, "content": content})
            process_line(content, header_stack, name_dict, True)
        else:
            plain_text = block.get('c', [''])[0]
            for line in plain_text.split('\n'):
                process_line(line, header_stack, name_dict, False)

    return name_dict

def generate_output(name_dict: Dict[str, List[Dict[str, Any]]]) -> List[Dict[str, Any]]:
    sorted_names = sorted(name_dict.keys())
    new_blocks = []
    prev_header_stack = {}

    for name in sorted_names:
        if name not in prev_header_stack:
            prev_header_stack[name] = []
        new_blocks.append({"t": "Header", "level": 3, "c": [["", [], []], [], [name]]})
        entries = sorted(name_dict[name], key=lambda x: x["order"])
        for entry in entries:
            stored_header_stack = [header["content"] for header in entry["headers"]]
            h_index = 0
            for j, header in enumerate(entry["headers"]):
                if j < len(prev_header_stack[name]) and prev_header_stack[name][j] == header["content"]:
                    h_index = j + 1
                else:
                    break
            prev_header_stack[name] = stored_header_stack
            header_text = ""
            for i in range(h_index, len(entry["headers"])):
                header = entry["headers"][i]
                header_text += ">" * header["level"] + " " + header["content"] + "\n"
            if header_text:
                new_blocks.append({"t": "RawBlock", "c": ["markdown", header_text]})
            if entry["content"]:
                new_blocks.append({"t": "Para", "c": [{"t": "Str", "c": entry["content"]}]})

    return new_blocks

def main(doc):
    print("Running brackets extension")
    name_dict = process_document(doc['blocks'])
    new_blocks = generate_output(name_dict)
    return {"blocks": new_blocks, "meta": doc['meta']}

if __name__ == "__main__":
    import sys
    import json

    input_json = json.load(sys.stdin)
    output = main(input_json)
    json.dump(output, sys.stdout)