local pandoc = require 'pandoc'

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


-- Functions for excluding and ignoring names
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

-- Function to create a shallow copy of a table
local function shallow_copy(t)
    local t_copy = {}
    for k, v in pairs(t) do
        t_copy[k] = v
    end
    return t_copy
end

-- Global order counter
local order_counter = 0

-- Function to process each line
local function process_line(line, header_stack, name_dict)
  order_counter = order_counter + 1
  print(order_counter)
  print("Header stack submitted to process_line:")
  print_table(header_stack)

  -- Check if line contains bracketed content
  for bracketed_content in line:gmatch('%[(.-)%]') do
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
          headers = shallow_copy(header_stack),
          content = line,
          order = order_counter
      }
      table.insert(name_dict[name], entry)
    end
    ::continue:: 
  end
end

-- Function to process the entire document
function Pandoc(doc)
  local plain_text = pandoc.write(doc, 'plain')
  local name_dict = {}
  local header_stack = {}
  
  -- Split plain text into lines and process each line
  for line in plain_text:gmatch("[^\r\n]+") do
    -- Simulate header stack handling
    if line:match("^#+") then
      print ("header found:")
      print (line)
      local level = #line:match("^#+")  -- Count the number of leading '#' to determine header level
      while #header_stack > 0 and header_stack[#header_stack].level >= level do
        table.remove(header_stack)
      end
      table.insert(header_stack, {level = level, content = line})
    else
      -- Process non-header lines
      process_line(line, header_stack, name_dict)
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
      local stored_header_stack = {}
      for i, header in ipairs(entry.headers) do
        stored_header_stack[i] = header.content
      end

      local i = 1
      while i <= #entry.headers do
        if prev_header_stack[name][i] and prev_header_stack[name][i] == entry.headers[i].content then
          table.remove(entry.headers, i)
        else
          break
        end
      end
      prev_header_stack[name] = stored_header_stack

      local header_text = ""
      for i, header in ipairs(entry.headers) do
        header_text = header_text .. string.rep(">", header.level) .. " " .. header.content .. "\n"
      end
      
      if header_text ~= "" then
        table.insert(new_blocks, pandoc.RawBlock('markdown', header_text))
      end
      table.insert(new_blocks, pandoc.Para(pandoc.Str(entry.content)))
    end
  end

  return pandoc.Pandoc(new_blocks, doc.meta)
end
