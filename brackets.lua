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

local function process_block(block, header_stack, name_dict)
  if block.t == 'Para' or block.t == 'Plain' then
    local content = pandoc.utils.stringify(block)
    for bracketed_content in content:gmatch('%[(.-)%]') do
      if should_ignore(bracketed_content) then
        goto continue
      end
      for name in bracketed_content:gmatch('[^,]+') do
        if should_exclude(name) then
          goto continue
        end
        print("Processing name:", name)
        print("Current name_dict[name]:", name_dict[name])
        if name_dict[name] == nil then
            print("Initializing name_dict[name] for:", name)
            name_dict[name] = {}
        end
        print("Current header_stack:", header_stack)
        local entry = {
            header_stack = header_stack or {},  -- Safeguard against nil header_stack
            content = content or ""  -- Safeguard against nil content
        }
        table.insert(name_dict[name], entry)
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
  local prev_header_stack = {}
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
    if not prev_header_stack[name] then
      prev_header_stack[name] = {}
    end
    table.insert(new_blocks, pandoc.Header(3, name))
    for _, entry in ipairs(name_dict[name]) do
      local stored_header_stack = {}
      for i, header in ipairs(entry.header_stack) do
        stored_header_stack = header
      end
      local i = 1
      while i <= #entry.header_stack do
        if prev_header_stack[name][i] and prev_header_stack[name][i] == pandoc.utils.stringify(entry.header_stack[i]) then
          table.remove(entry.header_stack, i)
        else
          break
        end
      end
      prev_header_stack[name] = stored_header_stack
      local header_output = ""
      for i, header in ipairs(entry.header_stack) do
        header_text = header_output .. string.rep(">", header.level) .. " " .. pandoc.utils.stringify(header) .. "\n"
      end
      table.insert(new_blocks, pandoc.RawBlock('markdown', header_text))
      table.insert(new_blocks, pandoc.Para {})
      for _, line in ipairs(entry.content) do
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
