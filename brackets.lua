local pipe = pandoc.pipe

function pull_names(content)
  -- Specify the path to your Python script
  local py_script_path = "brackets.py"

  -- Run the Python script and pass the content to it
  local result = pipe('python', {py_script_path}, content)
  
  if result == "" then
    return {}
  end
  
  -- Parse the result as Markdown and return the blocks
  return pandoc.read(result, "markdown").blocks
end

function Pandoc(doc)
  -- Convert the document to markdown to get the raw content
  local content = pandoc.write(doc, 'markdown')
  
  -- Process the content with the Python script
  local processed_blocks = pull_names(content)
  
  -- Append the processed blocks to the original document
  for _, block in ipairs(processed_blocks) do
    table.insert(doc.blocks, block)
  end
  
  -- Return the modified document
  return doc
end