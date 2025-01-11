#!/usr/bin/env python3
'''
Pulls out text in square brackets from markdown files 
in original (or Atx) markdown format.
Usage: python3 brackets.py <input_file_or_dir> <output_file>
- If input_file_or_dir is a directory, reads all files 
whose names end in "md" (note, no "." so .qmd and .md files are read)
- Hidden files ignored if the name startswith '.' or '_'
- `-r` specifies recursive search of subdirectories
'''

import re
import os
import sys
import argparse
from contextlib import contextmanager

#-------------------
@contextmanager
def change_dir(newdir):
    prevdir = os.getcwd()
    os.chdir(newdir)     
    try:
        yield
    finally:
        os.chdir(prevdir)
#-------------------

default_output_filename = "auto-brackets.md"
exclude_names = ["x", "X", "[ ]"]
exclude_stems = ["@","!"]
exclude_prefixes = [".","_"] # exclude all dirs and files that start with these
file_end = "md" # include all files that end in this
ignored_filenames=[
    "README.md"
]
#-------------------

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
    if len(theselines)==0:
        return theselines
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
                output.append(f"\n{headers}\n")
            if len(entry['content'].strip()) > 0:
                output.append(f"{entry['content']}  \n".strip())
        output.append("")
    return "\n".join(output)

def readfiles(input_path, recursive=False):
    if os.path.isfile(input_path):
        return [input_path]
    if not os.path.isdir(input_path):
        return []
    input_files = []
    for item in sorted(os.listdir(input_path)):
        skip_this_item = False
        for prefix in exclude_prefixes:
            if item.startswith(prefix):
                skip_this_item = True
                break
        if skip_this_item:
            continue
        full_path = os.path.join(input_path, item)
        if os.path.isfile(full_path) and item.endswith(file_end) and item not in ignored_filenames:
            input_files.append(full_path)
        elif recursive and os.path.isdir(full_path):
            input_files.extend(readfiles(full_path, recursive=True))
    return input_files

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process files or directories.")
    parser.add_argument(
        "input_filepath",
        nargs="?",
        default="./",
        help="Path to input file or directory. Defaults to './'"
    )
    parser.add_argument(
        "output_file",
        nargs="?",
        default=default_output_filename,
        help="Path to the output file. Defaults to 'auto-brackets.md'"
    )
    parser.add_argument(
        "-r", "--recursive",
        action="store_true",
        default=False,
        help="Process directories recursively. Defaults to False."
    )
    args = parser.parse_args()

    input_filepath = args.input_filepath
    output_file = args.output_file
    ignored_filenames.append(os.path.split(output_file)[-1])
    input_files = readfiles(input_filepath, recursive=args.recursive)

    final_dict = {}
    print ("ignored_filenames: ", "|".join(ignored_filenames))
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
    text = format_output(final_dict)
    with open(output_file, 'w') as f:
        f.write(text)
    sys.stdout.flush()


