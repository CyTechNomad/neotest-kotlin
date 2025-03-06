local lib = require("neotest.lib")
local position_parser = require("src.position-parser")
local package_query = require("src.treesitter.package-query")
local class_query = require("src.treesitter.class-query")
local async = require("neotest.async")
local command = require("src.command")
local filter = require("src.filter")
local treesitter_query = require("junit-treesitter-query")
local output_parser = require("src.output-parser")

local adapter = { name = "neotest-junit" }

function adapter.root(dir)
    return lib.files.match_root_pattern("gradlew")(dir)
end

function adapter.filter_dir(name, rel_path, root)
    return filter.is_test_directory(name)
end

function adapter.is_test_file(name, rel_path, root)
    return filter.is_test_file(name)
end

local function get_match_type(captured_nodes)
    if captured_nodes["namespace.name"] then
        return "namespace"
    end
    if captured_nodes["test.name"] then
        return "test"
    end
end

function adapter.build_position(file_path, source, captured_nodes)
    local match_type = get_match_type(captured_nodes)
    local definition = captured_nodes[match_type .. ".definition"]

    -- Extract test function name if present
    local function_name = captured_nodes["test.name"]
        and vim.treesitter.get_node_text(captured_nodes["test.name"], source)
        or nil

    local build_position = {
        type = match_type,
        path = file_path,
        range = { definition:range() },
        name = function_name, -- Store the function name for later use
    }

    return build_position
end

--- Discover test positions within a file using Treesitter.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function adapter.discover_positions(path)
    local positions = lib.treesitter.parse_positions(path, treesitter_query.value, {
        nested_namespaces = true,
        nested_tests = false,
    })
    return positions
end

---@param args neotest.run.RunArgs
---@return nil | neotest.RunSpec | neotest.RunSpec[]
function adapter.build_spec(args)
    local results_path = async.fn.tempname() .. ".json"

    -- Ensure there's an output file to stream test results
    lib.files.write(results_path, "")

    local tree = args.tree
    if not tree then
        return
    end

    local pos = tree:data()
    local root = adapter.root(pos.path)

    -- Extract package and class name
    local pkg = position_parser.get_first_match_string(pos.path, package_query)
    local className = position_parser.get_first_match_string(pos.path, class_query)
    local specPackage = pkg .. "." .. className

    -- Extract function name from `pos`
    local test_function = pos.name or "*"

    -- Generate the Gradle command
    local gradle_command = command.parse(test_function, specPackage, results_path)

    -- Setup streaming for results
    local stream_data, stop_stream = lib.files.stream_lines(results_path)

    print("command: " .. gradle_command)

    local all_results = {}

    return {
        command = gradle_command,
        cwd = root,
        context = {
            all_results = all_results,
            results_path = results_path,
            file = pos.path,
            stop_stream = stop_stream,
        },
        stream = function()
            return function()
                local new_results = stream_data()
                local success, parsed_result = pcall(output_parser.lines_to_results, new_results, pos.path, specPackage)
                if not success then
                    print("An error occurred while streaming data: " .. vim.inspect(err) .. " new_results: " .. vim.inspect(new_results))
                    return nil
                else
                    for k, v in pairs(parsed_result) do all_results[k] = v end
                    return parsed_result
                end
            end
        end,
    }
end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
function adapter.results(spec, result, tree)
    spec.context.stop_stream()
    return spec.context.all_results
end

return adapter

