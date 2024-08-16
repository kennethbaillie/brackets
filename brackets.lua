local pandoc = require 'pandoc'

-- List of names to exclude
local exclude_names = { ["doi"] = true, ["pmid"] = true, ["x"] = true, ["X"] = true, ["[ ]"] = true }

-- Function to check if a name should be excluded
local function should_exclude(name)
  return exclude_names[name] ~= nil
end

-- Function to check if any comma-separated elements begin with "DOI" or "PMID"
local function should_ignore(bracketed_content)
  for name in bracketed_content:gmatch('[^,]+') do
    name = name:match('^%s*(.-)%s*$') -- trim whitespace
    if name:match('^DOI') or name:match('^PMID') then
      return true
    end
  end
  return false
end

-- Function to process a block and extract names
local function process_block(block, header_stack, name_dict)
  if block.t == 'Para' or block.t == 'Plain' then
    -- Convert the block to plain text
    local content = pandoc.utils.stringify(block)

    -- Find all names in square brackets
    for bracketed_content in content:gmatch('%[(.-)%]') do
      -- Ignore if any comma-separated elements begin with "DOI" or "PMID"
      if should_ignore(bracketed_content) then
        goto continue
      end

      -- Split the bracketed content into individual names and sort them
      local names = {}
      for name in bracketed_content:gmatch('[^,]+') do
        name = name:match('^%s*(.-)%s*$') -- trim whitespace
        if not should_exclude(name) then
          table.insert(names, name)
        end
      end
      table.sort(names)

      -- Process each sorted name
      for _, name in ipairs(names) do
        -- Ensure the name has an entry in the name_dict
        if not name_dict[name] then
          name_dict[name] = {}
        end

        -- Gather the header trail as plain text with ">" separator
        local header_text = ""
        for _, header in ipairs(header_stack) do
          header_text = header_text .. string.rep(">", header.level) .. " " .. pandoc.utils.stringify(header) .. "\n"
        end

        -- Add the header trail and the paragraph to the name's list
        if #header_text > 0 then
          if not name_dict[name][header_text] then
            name_dict[name][header_text] = {}
          end
          table.insert(name_dict[name][header_text], block)
        end
      end
      ::continue::
    end
  elseif block.t == 'BulletList' or block.t == 'OrderedList' then
    for _, item in ipairs(block.content) do
      for _, subblock in ipairs(item) do
        process_block(subblock, header_stack, name_dict)
      end
    end
  elseif block.t == 'DefinitionList' then
    for _, item in ipairs(block.content) do
      for _, subblock in ipairs(item[2]) do
        for _, subsubblock in ipairs(subblock) do
          process_block(subsubblock, header_stack, name_dict)
        end
      end
    end
  end
end

-- Function to extract lines by name and trace back headers
local function extract_lines_by_name(blocks)
  local name_dict = {}
  local header_stack = {}

  -- Iterate through each block in the document
  for _, block in ipairs(blocks) do
    if block.t == 'Header' then
      -- Pop headers from the stack if the new header is of the same or higher level
      while #header_stack > 0 and header_stack[#header_stack].level >= block.level do
        table.remove(header_stack)
      end
      -- Push the current header onto the stack
      table.insert(header_stack, block)
    else
      process_block(block, header_stack, name_dict)
    end
  end

  -- Create new blocks for each name
  local new_blocks = {}
  local sorted_names = {}

  -- Collect all names for sorting
  for name in pairs(name_dict) do
    table.insert(sorted_names, name)
  end

  -- Sort names alphabetically
  table.sort(sorted_names)

  -- Create blocks for each sorted name
  for _, name in ipairs(sorted_names) do
    local sections = name_dict[name]
    table.insert(new_blocks, pandoc.Header(1, name))
    local reported_headers = {}
    for header_text, lines in pairs(sections) do
      if not reported_headers[header_text] then
        table.insert(new_blocks, pandoc.Plain { pandoc.Str(header_text) })
        reported_headers[header_text] = true
      end
      for _, line in ipairs(lines) do
        table.insert(new_blocks, line)
      end
    end
  end

  return new_blocks
end

function Pandoc(doc)
  local processed_blocks = extract_lines_by_name(doc.blocks)
  return pandoc.Pandoc(processed_blocks, doc.meta)
end
