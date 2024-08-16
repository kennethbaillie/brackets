local pandoc = require 'pandoc'

local exclude_names = { ["x"] = true, ["X"] = true, ["[ ]"] = true }
local function should_exclude(name)
  return exclude_names[name] ~= nil
end

local function should_ignore(bracketed_content)
  for name in bracketed_content:gmatch('[^,]+') do
    name = name:match('^%s*(.-)%s*$') -- trim whitespace
    if name:match('^DOI') or name:match('^PMID') then
      return true
    end
  end
  return false
end

prev_header_stack = {}
local function process_block(block, header_stack, name_dict)
  if block.t == 'Para' or block.t == 'Plain' then
    local content = pandoc.utils.stringify(block)

    for bracketed_content in content:gmatch('%[(.-)%]') do
      if should_ignore(bracketed_content) then
        goto continue
      end

      local names = {}
      for name in bracketed_content:gmatch('[^,]+') do
        if not should_exclude(name) then
          table.insert(names, name)
        end
      end
      table.sort(names)

      for _, name in ipairs(names) do
        if not name_dict[name] then
          name_dict[name] = {}
        end

        if not prev_header_stack[name] then
          prev_header_stack[name] = {}
        end
        
        local stored_header_stack = {}
        for i, header in ipairs(header_stack) do
          stored_header_stack[i] = header
        end

        local i = 1
        while i <= #header_stack do
          if prev_header_stack[name][i] and prev_header_stack[name][i] == pandoc.utils.stringify(header_stack[i]) then
            table.remove(header_stack, i)
          else
            break
          end
        end
        prev_header_stack[name] = stored_header_stack

        local output_text = ""
        for i, header in ipairs(header_stack) do
          print("Index: " .. i)
          print("Header: " .. pandoc.utils.stringify(header))
          print("Header level: " .. pandoc.utils.stringify(header.level))
          output_text = output_text .. string.rep(">", header.level) .. " " .. pandoc.utils.stringify(header) .. "\n"
        end
        if #output_text > 0 then
          if not name_dict[name][output_text] then
            name_dict[name][output_text] = {}
          end
          table.insert(name_dict[name][output_text], block)
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

local function extract_lines_by_name(blocks)
  local name_dict = {}
  local header_stack = {}

  for _, block in ipairs(blocks) do
    if block.t == 'Header' then
      while #header_stack > 0 and header_stack[#header_stack].level >= block.level do
        table.remove(header_stack)
      end
      table.insert(header_stack, block)
    else
      process_block(block, header_stack, name_dict)
    end
  end

  local new_blocks = {}
  local sorted_names = {}

  for name in pairs(name_dict) do
    table.insert(sorted_names, name)
  end

  table.sort(sorted_names)

  for _, name in ipairs(sorted_names) do
    local sections = name_dict[name]
    table.insert(new_blocks, pandoc.Header(3, name))
    local reported_headers = {}
    for header_text, lines in pairs(sections) do
      if not reported_headers[header_text] then
        table.insert(new_blocks, pandoc.RawBlock('markdown', header_text))
        table.insert(new_blocks, pandoc.Para {}) -- End the paragraph after the header
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
