-- _extensions/brackets/brackets.lua
local pandoc = require("pandoc")

-- Function to call the Python script and capture its output
function get_bracket_text(file_content)
  -- Create a temporary file to store the input text
  local temp_file = os.tmpname()
  local temp_output = os.tmpname()

  -- Write the file content to the temporary input file
  local f = io.open(temp_file, "w")
  f:write(file_content)
  f:close()

  -- Call the Python script with the temporary input file
  os.execute("python3 _extensions/brackets/brackets.py " .. temp_file .. " " .. temp_output)

  -- Read the output from the temporary output file
  local f_output = io.open(temp_output, "r")
  local result = f_output:read("*all")
  f_output:close()

  -- Clean up the temporary files
  os.remove(temp_file)
  os.remove(temp_output)

  return result
end

-- Pandoc filter to process the entire document
function Pandoc(doc)
  -- Get the entire text of the document
  local doc_text = pandoc.utils.stringify(doc)

  -- Call the Python script and get the processed result
  local output = get_bracket_text(doc_text)

  -- Return the output as a list of blocks (RawBlock in markdown)
  return pandoc.Pandoc({ pandoc.RawBlock("markdown", output) })
end
