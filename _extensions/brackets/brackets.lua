local pandoc = require("pandoc")

function get_bracket_text(file_path)
  local temp_output = os.tmpname()  -- Temporary file for Python's output
  os.execute("python3 _extensions/brackets/brackets.py " .. file_path .. " " .. temp_output)
  return temp_output
end

function Pandoc(doc)
  local temp_output_file = get_bracket_text(PANDOC_STATE.input_files[1])
  local new_doc = pandoc.read(io.open(temp_output_file, "r"):read("*all"))
  os.remove(temp_output_file)
  return new_doc
end
