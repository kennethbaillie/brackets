#!/usr/bin/env python3
'''
Pulls out text in square brackets from markdown files 
in original (or Atx) markdown format.
Usage: python3 brackets.py <input_file_or_dir> <output_file>
If input_file_or_dir is a directory, reads all files 
whose names end in "md" 
(note, no "." so .qmd and .md files are read)
Hidden files ignored if the name startswith '.' or '_'
'''

import re
import os
import sys

#-------------------
from contextlib import contextmanager
@contextmanager
def change_dir(newdir):
    prevdir = os.getcwd()
    os.chdir(newdir)     
    try:
        yield
    finally:
        os.chdir(prevdir)
#-------------------

exclude_names = ["x", "X", "[ ]"]
exclude_stems = ["@","!"]
def should_exclude(name):
    if name in exclude_names:
        return True
    for stem in exclude_stems:
        if name.startswith(stem):
            return True
    else:
        return False

def should_ignore(bracketed_content):
    return any(re.match(r'^(DOI|PMID)', name.strip()) for name in re.split(r',\s*', bracketed_content))

def remove_yaml(theselines):
    if theselines[0].strip() == "---":
        for i in range(1, len(theselines)):
            if theselines[i].strip() in ("---", "..."):
                return theselines[i + 1:]
    return theselines

def process_line(line, header_stack, name_dict, header_match):
    #bracketed_contents = re.findall(r'\[(.*?)\]', line)
    bracketed_contents = re.findall(r'\[(?!.*?\(http)(.*?)\]', line)
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
        if name.strip() == '':
            continue
        output.append(f"# {name}\n")
        for entry in entries:
            headers = " > ".join([h for h in entry["headers"]])
            if len(headers.replace(">","").strip()) > 0:
                output.append(f"{headers}\n")
            if len(entry['content'].strip()) > 0:
                output.append(f"{entry['content']}")
        output.append("")
    return "\n".join(output)

ignored_files=[
    "README.md"
]
def readfiles(input_path):
    if os.path.isdir(input_path):
        input_files = [
            os.path.join(input_path, x) for x in os.listdir(input_path) 
            if x.endswith("md") 
            and not(x.startswith("_")) 
            and not(x.startswith(".")) 
            and not(os.path.isdir(x))
            and not x in ignored_files
            ]
    else:
        input_files = [input_path]
    return input_files

if __name__ == "__main__":
    input_filepath = sys.argv[1]
    output_file = sys.argv[2]
    ignored_files.append(os.path.split(output_file)[-1])
    input_files = readfiles(input_filepath)
    final_dict = {}
    print ("ignored_files", "|".join(ignored_files))
    for input_file in input_files:
        print (input_file)
        thisdir, filename = os.path.split(input_file)
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


