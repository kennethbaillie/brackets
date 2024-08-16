# combine_scripts.py
import os

# Define file paths
lua_file = "brackets_source.lua"
py_file = "brackets.py"
output_file = "brackets.lua"

# Read the Lua script
with open(lua_file, 'r') as lf:
    lua_content = lf.read()

# Read the Python script
with open(py_file, 'r') as pf:
    py_content = pf.read()

# Escape special characters in the Python script to safely include it in a Lua string
escaped_py_content = py_content.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")

# Embed the Python script into the Lua script
combined_content = lua_content.replace(']] .. [[brackets.py]]', escaped_py_content)

# Write the combined content to a new Lua file
with open(output_file, 'w') as of:
    of.write(combined_content)

print(f"Combined script created: {output_file}")
