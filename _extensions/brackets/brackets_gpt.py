import re

# Dictionary of names to exclude
exclude_names = {"x": True, "X": True, "[ ]": True}

# Check if a name should be excluded
def should_exclude(name):
    return name in exclude_names

# Check if bracketed content should be ignored
def should_ignore(bracketed_content):
    return any(re.match(r'^(DOI|PMID)', name.strip()) for name in re.split(r',\s*', bracketed_content))

# Main processing function
def process_line(line, header_stack, name_dict, is_header, order_counter):
    # Find all bracketed content
    bracketed_contents = re.findall(r'\[(.*?)\]', line)
    
    for content in bracketed_contents:
        if should_ignore(content):
            continue
        
        # Process names inside the brackets
        for name in re.split(r',\s*', content):
            name = name.strip()
            if should_exclude(name):
                continue
            
            # Create a new entry if name is not yet in the dictionary
            if name not in name_dict:
                name_dict[name] = []
            
            # Add the entry with headers and content
            entry = {
                "headers": header_stack.copy(),
                "content": "" if is_header else line,
                "order": order_counter
            }
            name_dict[name].append(entry)

# Function to process the document (list of lines)
def process_document(lines):
    name_dict = {}
    header_stack = []
    order_counter = 0
    
    for line in lines:
        # Check for headers (e.g., '# Header', '## Subheader')
        header_match = re.match(r'^(#+)\s*(.*)', line)
        
        if header_match:
            level = len(header_match.group(1))  # Header level
            content = header_match.group(2)     # Header content
            
            # Adjust header stack based on levels
            header_stack = [h for h in header_stack if h['level'] < level]
            header_stack.append({"level": level, "content": content})
            
            # Process the header line
            order_counter += 1
            process_line(content, header_stack, name_dict, True, order_counter)
        else:
            # Process regular lines
            order_counter += 1
            process_line(line, header_stack, name_dict, False, order_counter)
    
    return name_dict

# Example input
document = """
# Header 1
Some text with [name1, name2] and [x].
## Subheader 1.1
More text with [DOI: 12345] and [name3].
## Subheader 1.2
Even more text with [name2] and [PMID: 67890].
"""

# Simulate reading the document as lines
lines = document.strip().split('\n')

# Process the document
name_dict = process_document(lines)

# Display processed content in a readable format
def display_processed_content(name_dict):
    output = []
    for name, entries in name_dict.items():
        output.append(f"Name: {name}")
        for entry in entries:
            headers = " > ".join([h["content"] for h in entry["headers"]])
            output.append(f"  Headers: {headers}")
            output.append(f"  Content: {entry['content']}")
            output.append(f"  Order: {entry['order']}")
        output.append("")
    
    return "\n".join(output)

# Output the processed content
processed_content = display_processed_content(name_dict)
print(processed_content)
