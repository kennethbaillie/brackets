import re
from collections import defaultdict
from IPython.display import display, Markdown

def extract_and_display_names():
    from IPython import get_ipython
    ip = get_ipython()
    
    if ip is None:
        raise RuntimeError("This function must be run in an IPython environment (like Jupyter or Quarto).")
    
    # Get the content of the entire notebook/document
    cells = ip.run_cell_magic("capture", "", "%notebook -e")
    content = "\n".join(cell['source'] for cell in cells if cell['cell_type'] == 'markdown')

    def extract_lines(text):
        lines = text.split('\n')
        names_dict = defaultdict(list)
        current_headers = []
        headers_added = defaultdict(set)
        header_pattern = r'^(#+)\s+(.*)'  # Regex to find markdown headers
        name_pattern = r'\[(.*?)\]'       # Regex to find names in square brackets
        
        for line in lines:
            header_match = re.match(header_pattern, line)
            if header_match:
                header_level = len(header_match.group(1))
                header_text = header_match.group(2)
                current_headers = current_headers[:header_level - 1] + [header_text]
            
            name_matches = re.findall(name_pattern, line)
            for match in name_matches:
                names = [name.strip() for name in match.split(',')]
                for name in names:
                    header_lines = []
                    
                    for i, header in enumerate(current_headers):
                        header_string = f"{'#' * (i + 1)} {header}"
                        if header_string not in headers_added[name]:
                            header_lines.append(header_string)
                            headers_added[name].add(header_string)
                    
                    names_dict[name].append("\n".join(header_lines) + "\n" + line.strip())
        return names_dict

    lines_by_name = extract_lines(content)
    output_md = ""
    for name, lines in lines_by_name.items():
        output_md += f"# {name}\n\n"
        output_md += "\n\n".join(lines)
        output_md += "\n\n"
    display(Markdown(output_md))