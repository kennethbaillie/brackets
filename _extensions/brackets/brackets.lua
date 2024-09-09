-- _extensions/brackets/brackets.lua
local pandoc = require("pandoc")

function get_bracket_text(file_content)
  local temp_file = os.tmpname()
  local temp_output = os.tmpname()
  local f = io.open(temp_file, "w")
  f:write(file_content)
  f:close()
  os.execute("python3 _extensions/brackets/brackets.py " .. temp_file .. " " .. temp_output)
  local f_output = io.open(temp_output, "r")
  local result = f_output:read("*all")
  f_output:close()
  os.remove(temp_file)
  os.remove(temp_output)
  return result
end

function Pandoc(doc)
  local doc_text = pandoc.utils.stringify(doc)
  local output = get_bracket_text(doc_text)
  return pandoc.Pandoc({ pandoc.RawBlock("markdown", output) })
end
