local pipe = pandoc.pipe

function pull_names(content)
  local py_script = "brackets.py"
  local result = pipe('python', {py_script}, content)
  if result == "" then
    return {}
  end
  return pandoc.read(result, "markdown").blocks
end

function Meta(meta)
  meta.format = meta.format or {}
  meta.format.html = meta.format.html or {}
  meta.format.html.toc = true
  meta.format.html["toc-location"] = "left"
  return meta
end

function Pandoc(doc)
  local content = pandoc.write(doc, 'markdown')
  local processed_blocks = pull_names(content)
  local new_doc = pandoc.Pandoc(processed_blocks)
  new_doc.meta.title = pandoc.MetaString("People")
  new_doc.meta = Meta(new_doc.meta)
  print("ready")
  print(new_doc.meta)
  return new_doc
end
