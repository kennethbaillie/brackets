local pandoc = require("pandoc")
function get_script_directory()
  local str = debug.getinfo(1, "S").source:sub(2)  
  return str:match("(.*/)")
end

function get_bracket_text(file_path)
  local script_dir = get_script_directory()  
  local temp_output = os.tmpname()  
  local python_script_path = script_dir .. "brackets.py"
  os.execute("python3 " .. python_script_path .. " " .. file_path .. " " .. temp_output)
  local f_output = io.open(temp_output, "r")
  local result = f_output:read("*all")
  f_output:close()
  os.remove(temp_output)
  return result
end

function Pandoc(doc)
  local output = get_bracket_text(PANDOC_STATE.input_files[1])
  return pandoc.Pandoc({ pandoc.RawBlock("markdown", output) })
end


