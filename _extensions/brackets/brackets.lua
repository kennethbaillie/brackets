-- _extensions/brackets/brackets.lua
local pandoc = require("pandoc")

function get_bracket_text(file_path)
  local temp_output = os.tmpname()  -- Temporary file for Python's output
  os.execute("python3 _extensions/brackets/brackets.py " .. file_path .. " " .. temp_output)
  local f_output = io.open(temp_output, "r")
  local result = f_output:read("*all")
  f_output:close()
  os.remove(temp_output)
  return result
end

function Pandoc(doc)
  local original_file_path = PANDOC_STATE.input_files[1]  -- Access the original file path
  local output = get_bracket_text(original_file_path)
  return pandoc.Pandoc({ pandoc.RawBlock("markdown", output) })
end
