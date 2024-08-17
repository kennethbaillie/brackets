function Pandoc(doc)
    -- Convert the entire document to plain text
    local plain_text = pandoc.write(doc, 'plain')

    -- Split the text into lines and process each line
    for line in plain_text:gmatch("[^\r\n]+") do
        -- Process each line here
        print("Processing line:", line)

        -- Example: Check for bracketed content
        for bracketed_content in line:gmatch('%[(.-)%]') do
            print("Found bracketed content:", bracketed_content)
            -- You can process the bracketed content further here
        end
    end

    -- Return the modified or original document as required
    return doc
end
