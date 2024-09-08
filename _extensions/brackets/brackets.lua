local pandoc = require 'pandoc'

function Pandoc(doc)
    print("Running Lua bridge to Python brackets extension (new approach)")

    -- Convert the Pandoc document to plain text
    local plain_text = pandoc.write(doc, 'plain')

    -- Create a temporary file for input
    local input_file = os.tmpname()
    local f = io.open(input_file, 'w')
    f:write(plain_text)
    f:close()

    -- Create a temporary file for output
    local output_file = os.tmpname()

    -- Call the Python script
    local command = string.format("python3 _extensions/brackets/brackets.py < %s > %s 2>brackets_error.log", input_file, output_file)
    local exit_code = os.execute(command)

    if exit_code ~= 0 then
        local error_log = io.open("brackets_error.log", "r")
        local error_message = error_log:read("*all")
        error_log:close()
        error("Python script execution failed: " .. error_message)
    end

    -- Read the output
    local f = io.open(output_file, 'r')
    local output_text = f:read('*all')
    f:close()

    -- Clean up temporary files
    os.remove(input_file)
    os.remove(output_file)
    os.remove("brackets_error.log")

    -- Parse the output text back into a Pandoc document
    local new_doc = pandoc.read(output_text, 'markdown')

    return new_doc
end