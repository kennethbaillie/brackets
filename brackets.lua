local pandoc = require 'pandoc'
local order_counter

---------
local function print_table(t, indent)
    indent = indent or 0
    local indent_str = string.rep("  ", indent)

    for key, value in pairs(t) do
        if type(value) == "table" then
            print(indent_str .. tostring(key) .. ":")
            print_table(value, indent + 1)
        else
            print(indent_str .. tostring(key) .. ": " .. tostring(value))
        end
    end
end
---------

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

-- Global order counter
local order_counter = 0

-- Updated process_block function
local function process_block(block, header_stack, name_dict)
  order_counter = order_counter + 1
  print (order_counter)
  print ("Header stack")
  print_table(header_stack)
  if block.t == 'Para' or block.t == 'Plain' then
    local content = pandoc.utils.stringify(block)
    for bracketed_content in content:gmatch('%[(.-)%]') do
      if should_ignore(bracketed_content) then
        goto continue
      end
      for name in bracketed_content:gmatch('[^,]+') do
        name = name:match('^%s*(.-)%s*$') -- trim whitespace
        if should_exclude(name) then
          goto continue
        end
        if name_dict[name] == nil then
            name_dict[name] = {}
        end
        local entry = {
            header_stack = header_stack,
            content = content,
            order = order_counter
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
  local order_counter = 0

  -- Process blocks and build name_dict
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

  -- Sort names alphabetically
  local sorted_names = {}
  for name in pairs(name_dict) do
    table.insert(sorted_names, name)
  end
  table.sort(sorted_names)

  local new_blocks = {}
  local prev_header_stack = {}

  -- Iterate through sorted names
  for _, name in ipairs(sorted_names) do
    if not prev_header_stack[name] then
      prev_header_stack[name] = {}
    end
    table.insert(new_blocks, pandoc.Header(3, name))

    -- Sort entries for this name by their order
    local entries = name_dict[name]
    table.sort(entries, function(a, b) return a.order > b.order end)

    -- Process entries for this name
    for _, entry in ipairs(entries) do
      print_table(entry)
      local stored_header_stack = {}
      for i, header in ipairs(entry.header_stack) do
        stored_header_stack[i] = pandoc.utils.stringify(header)
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

      local header_text = ""
      for i, header in ipairs(entry.header_stack) do
        header_text = header_text .. string.rep(">", header.level) .. " " .. pandoc.utils.stringify(header) .. "\n"
      end
      
      if header_text ~= "" then
        table.insert(new_blocks, pandoc.RawBlock('markdown', header_text))
      end
      table.insert(new_blocks, pandoc.Para(pandoc.Str(entry.content)))
    end
  end

  return new_blocks
end


function Pandoc(doc)
  local processed_blocks = extract_lines_by_name(doc.blocks)
  return pandoc.Pandoc(processed_blocks, doc.meta)
end
