#!/usr/bin/env python3
'''
Pulls out text in square brackets from markdown files 
in original (or Atx) markdown format.
Usage: python3 brackets.py <input_file_or_dir> <output_file>
If input_file_or_dir is a directory, reads all files 
whose names end in "md" 
(note, no "." so .qmd and .md files are read)
'''

import re
import os
import sys

ignored_files=[
    "README.md"
]

exclude_names = ["x", "X", "[ ]"]
def should_exclude(name):
    return name in exclude_names

def should_ignore(bracketed_content):
    return any(re.match(r'^(DOI|PMID)', name.strip()) for name in re.split(r',\s*', bracketed_content))

def remove_yaml(theselines):
    if theselines[0].strip() == "---":
        for i in range(1, len(theselines)):
            if theselines[i].strip() in ("---", "..."):
                return theselines[i + 1:]
    return theselines

def process_line(line, header_stack, name_dict, header_match):
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
            if header_match:
                entry = {
                    "headers": header_stack.copy(),
                    "content": '',
                }
            else:
                entry = {
                    "headers": header_stack.copy(),
                    "content": line,
                }
            name_dict[name].append(entry)

def process_document(doclines, filename, dictlen):
    name_dict = {}
    header_stack = []
    if dictlen > 1:
        header_stack = [filename]
    print (header_stack)
    for line in doclines:
        header_match = re.match(r'^(#+)\s*(.*)', line)
        if header_match:
            level = len(header_match.group(1))
            content = header_match.group(2)
            header_stack =  header_stack[:level] + [content]
        process_line(line, header_stack, name_dict, header_match)
    name_dict = prune_headers(name_dict)
    return name_dict

def prune_headers(name_dict):
    for name, entries in name_dict.items():
        seen_headers = []
        pruned_entries = []
        for entry in entries:
            new_headers = []
            for header in entry['headers']:
                if header not in seen_headers:
                    new_headers.append(header)
                    seen_headers.append(header)
                else:
                    new_headers.append('')
            entry['headers'] = new_headers
            pruned_entries.append(entry)
        name_dict[name] = pruned_entries
    return name_dict

def format_output(name_dict):
    output = []
    for name, entries in name_dict.items():
        output.append(f"# {name}\n")
        for entry in entries:
            headers = " > ".join([h for h in entry["headers"]])
            if len(headers.replace(">","").strip()) > 0:
                output.append(f"{headers}\n")
            if len(entry['content'].strip()) > 0:
                output.append(f"{entry['content']}")
        output.append("")
    return "\n".join(output)
    
if __name__ == "__main__":
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    if os.path.isdir(input_file):
        input_files = [
            x for x in os.listdir(input_file) 
            if x.endswith("md") 
            and not(os.path.isdir(x))
            and not x in ignored_files
            ]
    else:
        input_files = [input_file]
    final_dict = {}
    for input_file in input_files:
        print (input_file)
        filename = os.path.split(input_file)[-1]
        print ("filename", filename)
        with open(input_file, 'r') as f:
            lines = f.readlines()
        lines = remove_yaml(lines)
        name_dict = process_document(lines, filename, len(input_files))
        for key, value in name_dict.items():
            if key in final_dict:
                final_dict[key].extend(value)
            else:
                final_dict[key] = value
        print (final_dict)
    text = format_output(final_dict)
    with open(output_file, 'w') as f:
        f.write(text)
    sys.stdout.flush()


