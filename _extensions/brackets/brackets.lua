local pandoc = require 'pandoc'

function Pandoc(doc)
    print("Running Lua bridge to Python brackets extension")

    -- Convert the Pandoc document to JSON
    local json_input = pandoc.write(doc, 'json')

    -- Create a temporary file for input
    local input_file = os.tmpname()
    local f = io.open(input_file, 'w')
    f:write(json_input)
    f:close()

    -- Create a temporary file for output
    local output_file = os.tmpname()

    -- Call the Python script
    local pythonscript = "_extensions/brackets/brackets.py"
    local command = string.format("python3 %s < %s > %s", pythonscript, input_file, output_file)
    local exit_code = os.execute(command)

    if exit_code ~= 0 then
        error("Python script execution failed")
    end

    -- Read the output
    local f = io.open(output_file, 'r')
    local json_output = f:read('*all')
    f:close()

    -- Clean up temporary files
    os.remove(input_file)
    os.remove(output_file)

    -- Parse the JSON output back into a Pandoc document
    local success, result = pcall(pandoc.read, json_output, 'json')
    if not success then
        error("Failed to parse JSON output from Python script")
    end

    return result
end