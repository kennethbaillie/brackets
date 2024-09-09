import re
import os
import sys

exclude_names = ["x", "X", "[ ]"]
def should_exclude(name):
    return name in exclude_names

def should_ignore(bracketed_content):
    return any(re.match(r'^(DOI|PMID)', name.strip()) for name in re.split(r',\s*', bracketed_content))

def remove_yaml(theselines):
    if theselines[0].strip() == "---":
        print ("starts with ---")
        for i in range(1, len(theselines)):
            if theselines[i].strip() in ("---", "..."):
                print ("end found", i)
                return theselines[i + 1:]
    return theselines

def process_line(line, header_stack, name_dict, is_header, order_counter):
    bracketed_contents = re.findall(r'\[(.*?)\]', line)
    for content in bracketed_contents:
        if should_ignore(content):
            continue
        for name in re.split(r',\s*', content):
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

def process_document(doclines):
    name_dict = {}
    header_stack = []
    order_counter = 0
    for line in doclines:
        header_match = re.match(r'^(#+)\s*(.*)', line)
        if header_match:
            level = len(header_match.group(1))
            content = header_match.group(2)   
            header_stack = [h for h in header_stack if h['level'] < level]
            header_stack.append({"level": level, "content": content})
            order_counter += 1
            process_line(content, header_stack, name_dict, True, order_counter)
        else:
            order_counter += 1
            process_line(line, header_stack, name_dict, False, order_counter)
    return name_dict

def dict_to_file(name_dict):
    output = []
    for name, entries in name_dict.items():
        output.append(f"# {name}")
        for entry in entries:
            headers = " > ".join([h["content"] for h in entry["headers"]])
            output.append(f"  {headers}")
            output.append(f"  {entry['content']}")
        output.append("")
    return "\n".join(output)
    
if __name__ == "__main__":
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    if os.path.isdir(input_file):
        input_files = [x for x in os.listdir(input_file) if not(os.path.isdir(x)) and not(x.endswith("md"))]
    else:
        input_files = [input_file]
    final_dict = {}
    for input_file in input_files:
        with open(input_file, 'r') as f:
            lines = f.readlines()
        lines = remove_yaml(lines)
        name_dict = process_document(lines)
    
    outlines = dict_to_file(name_dict)
    with open(output_file, 'w') as f:
        f.write(outlines)
    sys.stdout.flush()


