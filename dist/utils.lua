module ("dist.utils", package.seeall)

local pl = require "pl.import_into"()


-- Obtain LuaDist location by checking available package locations
function get_luadist_location()
  local paths = {}
  package.path:gsub("([^;]+)", function(c) table.insert(paths, c) end)

  for _, curr_path in pairs(paths) do
    if (pl.path.isabs(curr_path) and curr_path:find("[/\\]lib[/\\]lua[/\\]%?.lua$")) then
      -- Remove path to lib/lua
      curr_path = curr_path:gsub("[/\\]lib[/\\]lua[/\\]%?.lua$", "")
      -- Clean the path up a bit
      curr_path = curr_path:gsub("[/\\]bin[/\\]%.[/\\]%.%.", "")
      curr_path = curr_path:gsub("[/\\]bin[/\\]%.%.", "")
      return curr_path
    end
  end
  return nil
end

-- Return string argument quoted for a command line usage
function quote(argument)
    assert(type(argument) == "string", "utils.quote: Argument 'argument' is not a string.")

    -- replace '/' path separators for '\' on Windows
    if pl.path.is_windows and argument:match("^[%u%U.]?:?[/\\].*") then
        argument = argument:gsub("//","\\"):gsub("/","\\")
    end

    -- Windows doesn't recognize paths starting with two slashes or backslashes
    -- so we double every backslash except for the first one
    if pl.path.is_windows and argument:match("^[/\\].*") then
        local prefix = argument:sub(1,1)
        argument = argument:sub(2):gsub("\\",  "\\\\")
        argument = prefix .. argument
    else
        argument = argument:gsub("\\",  "\\\\")
    end
    argument = argument:gsub('"',  '\\"')

    return '"' .. argument .. '"'
end

-- Returns true if name of package 'pkg' partially matches at least one provided string
-- in table 'strings', case is ignored, returns true if table 'strings' is empty
function name_matches(pkg, strings)
    if strings == nil or #strings == 0 then
        return true
    end

    if type(strings) == "string" then
        strings = {strings}
    end

    assert(type(pkg) == "table", "utils.name_matches: Argument 'pkg' is not a table.")
    assert(type(strings) == "table", "utils.name_matches: Argument 'strings' is not a string or table.")

    for _, str in pairs(strings) do
        if tostring(pkg):find(str) ~= nil then
            return true
        end
    end

    return false
end

-- FIXME Delete or use logger
-- Print elements of table in a structured way, for debugging only
function print_table(tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      print_table(v, indent + 1)
    else
      print(formatting .. tostring(v))
    end
  end
end
