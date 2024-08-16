local pipe = pandoc.pipe

function pull_names(content)
  local py_script = "brackets.py"
  local result = pipe('python3', {py_script}, content)
  if result == "" then
    return {}
  end
  return pandoc.read(result, "markdown").blocks
end

function Pandoc(doc)
  local content = pandoc.write(doc, 'markdown')
  local processed_blocks = pull_names(content)
  local new_doc = pandoc.Pandoc(processed_blocks, doc.meta)
  new_doc.meta.title = pandoc.MetaString("People")
  new_doc.meta.editor["render-on-save"] = pandoc.MetaBool(true)
  --new_doc.meta["toc-title"] = pandoc.MetaString("TOC")
  --new_doc.meta.toc = pandoc.MetaBool(true)
  return new_doc
end
