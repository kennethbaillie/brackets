local pandoc = require 'pandoc'

local exclude_names = { ["x"] = true, ["X"] = true, ["[ ]"] = true }
local function should_exclude(name)
  return exclude_names[name] ~= nil
end

local function should_ignore(bracketed_content)
  for name in bracketed_content:gmatch('[^,]+') do
    name = name:match('^%s*(.-)%s*$') 
    if name:match('^DOI') or name:match('^PMID') then
      return true
    end
  end
  return false
end

local function shallow_copy(t)
    local t_copy = {}
    for k, v in pairs(t) do
        t_copy[k] = v
    end
    return t_copy
end

local order_counter = 0

local function process_line(line, header_stack, name_dict, is_header)
  order_counter = order_counter + 1
  for bracketed_content in line:gmatch('%[(.-)%]') do
    if should_ignore(bracketed_content) then
      goto continue
    end
    for name in bracketed_content:gmatch('[^,]+') do
      name = name:match('^%s*(.-)%s*$') 
      if should_exclude(name) then
        goto continue
      end
      if name_dict[name] == nil then
          name_dict[name] = {}
      end
      local entry = {
          headers = shallow_copy(header_stack),
          content = is_header and "" or line, 
          order = order_counter
      }
      table.insert(name_dict[name], entry)
    end
    ::continue:: 
  end
end

function Pandoc(doc)
  print ("Running brackets extension")
  local name_dict = {}
  local header_stack = {}

  for _, block in ipairs(doc.blocks) do
    if block.t == 'Header' then
      local level = block.level
      local content = pandoc.utils.stringify(block)
      while #header_stack > 0 and header_stack[#header_stack].level >= level do
        table.remove(header_stack)
      end
      table.insert(header_stack, {level = level, content = content})
      process_line(content, header_stack, name_dict, true)
    else
      local temp_doc = pandoc.Pandoc({block})
      local plain_text = pandoc.write(temp_doc, 'plain')
      for line in plain_text:gmatch("[^\r\n]+") do
        process_line(line, header_stack, name_dict, false)
      end
    end
  end

  local sorted_names = {}
  for name in pairs(name_dict) do
    table.insert(sorted_names, name)
  end
  table.sort(sorted_names)
  local new_blocks = {}
  local prev_header_stack = {}

  for _, name in ipairs(sorted_names) do
    if not prev_header_stack[name] then
      prev_header_stack[name] = {}
    end
    table.insert(new_blocks, pandoc.Header(3, name))
    local entries = name_dict[name]
    table.sort(entries, function(a, b) return a.order < b.order end)
    for _, entry in ipairs(entries) do
      local stored_header_stack = {}
      for i, header in ipairs(entry.headers) do
        stored_header_stack[i] = header.content
      end
      local h_index = 1
      for j, header in ipairs(entry.headers) do
        if (prev_header_stack[name][j] or "nil") == header.content then
          h_index = j+1
        else
          break
        end
      end
      prev_header_stack[name] = stored_header_stack
      local header_text = ""
      for i = h_index, #entry.headers do
        local header = entry.headers[i]
        if header then
          header_text = header_text .. string.rep(">", header.level) .. " " .. header.content .. "\n"
        end
      end
      if header_text ~= "" then
        table.insert(new_blocks, pandoc.RawBlock('markdown', header_text))
      end
      if entry.content ~= "" then
        table.insert(new_blocks, pandoc.Para(pandoc.Str(entry.content)))
      end
    end
  end

  return pandoc.Pandoc(new_blocks, doc.meta)
end
