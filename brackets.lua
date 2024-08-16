local pandoc = require 'pandoc'

-- List of names to exclude
local exclude_names = { ["X"] = true, ["x"] = true, ["doi"] = true, ["PMID"] = true }

-- Function to check if a name should be excluded
local function should_exclude(name)
  return exclude_names[name] ~= nil
end

-- Function to extract lines by name and trace back headers
local function extract_lines_by_name(blocks)
  local name_dict = {}
  local header_stack = {}

  -- Iterate through each block in the document
  for _, block in ipairs(blocks) do
    if block.t == 'Header' then
      -- Push the current header onto the stack
      table.insert(header_stack, block)
    elseif block.t == 'Para' then
      -- Convert the block to plain text
      local content = pandoc.utils.stringify(block)

      -- Find all names in square brackets
      for bracketed_content in content:gmatch('%[(.-)%]') do
        -- Split the bracketed content into individual names
        for name in bracketed_content:gmatch('[^,]+') do
          name = name:match('^%s*(.-)%s*$') -- trim whitespace
          if not should_exclude(name) then
            -- Ensure the name has an entry in the name_dict
            if not name_dict[name] then
              name_dict[name] = {}
            end

            -- Gather the header trail as plain text
            local header_text = ""
            for _, header in ipairs(header_stack) do
              header_text = header_text .. string.rep("  ", header.level) .. pandoc.utils.stringify(header) .. "\n"
            end

            -- Add the header trail and the paragraph to the name's list
            if #header_text > 0 then
              if not name_dict[name][header_text] then
                name_dict[name][header_text] = {}
              end
              table.insert(name_dict[name][header_text], block)
            end
          end
        end
      end
    end
  end

  -- Create new blocks for each name
  local new_blocks = {}
  for name, sections in pairs(name_dict) do
    -- Insert a header for the name
    table.insert(new_blocks, pandoc.Header(1, name))
    -- Insert the associated headers as plain text and lines
    for header_text, lines in pairs(sections) do
      table.insert(new_blocks, pandoc.Plain{pandoc.Str(header_text)})
      for _, line in ipairs(lines) do
        table.insert(new_blocks, line)
      end
    end
  end

  return new_blocks
end

-- Main Pandoc function
function Pandoc(doc)
  local processed_blocks = extract_lines_by_name(doc.blocks)
  
  -- Make sure editor exists in meta and is a table
  if not doc.meta.editor then
    doc.meta.editor = pandoc.MetaMap({})
  end
  doc.meta.title = pandoc.MetaString("People")
  doc.meta.editor["render-on-save"] = pandoc.MetaBool(true)
  
  return pandoc.Pandoc(processed_blocks, doc.meta)
end
