local pandoc = require 'pandoc'

-- Function to extract and categorize lines by names in square brackets
local function extract_lines_by_name(blocks)
  local name_dict = {}
  
  -- Iterate through each block in the document
  for _, block in pairs(blocks) do
    if block.t == 'Para' then
      -- Convert the block to plain text
      local content = pandoc.utils.stringify(block)

      -- Find lines with names in square brackets
      local name = content:match('%[(.-)%]')
      if name then
        -- Add the line to the corresponding name's list
        if not name_dict[name] then
          name_dict[name] = {}
        end
        table.insert(name_dict[name], block)
      end
    end
  end

  -- Create new blocks for each name
  local new_blocks = {}
  for name, lines in pairs(name_dict) do
    -- Insert a header for the name
    table.insert(new_blocks, pandoc.Header(1, name))
    -- Insert the associated lines
    for _, line in ipairs(lines) do
      table.insert(new_blocks, line)
    end
  end

  return new_blocks
end

-- Main Pandoc function
function Pandoc(doc)
  local new_blocks = extract_lines_by_name(doc.blocks)
  return pandoc.Pandoc(new_blocks, doc.meta)
end


