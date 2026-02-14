local M = {}

--- Format a value for display
---@param val any
---@return string
local function format_value(val)
  if val == nil or val == vim.NIL then
    return "NULL"
  elseif type(val) == "boolean" then
    return val and "true" or "false"
  else
    return tostring(val)
  end
end

--- Format columns and rows into an ASCII table
---@param columns string[]
---@param rows any[][]
---@return string[]
function M.ascii_table(columns, rows)
  if not columns or #columns == 0 then
    return { "(no columns)" }
  end

  -- Calculate column widths
  local widths = {}
  for i, col in ipairs(columns) do
    widths[i] = #col
  end
  for _, row in ipairs(rows) do
    for i, val in ipairs(row) do
      local s = format_value(val)
      if #s > widths[i] then
        widths[i] = #s
      end
    end
  end

  -- Cap column widths at 50
  for i, w in ipairs(widths) do
    if w > 50 then widths[i] = 50 end
  end

  -- Build separator line
  local sep_parts = {}
  for i, w in ipairs(widths) do
    sep_parts[i] = string.rep("-", w + 2)
  end
  local separator = "+" .. table.concat(sep_parts, "+") .. "+"

  -- Build header
  local header_parts = {}
  for i, col in ipairs(columns) do
    header_parts[i] = " " .. col .. string.rep(" ", widths[i] - #col) .. " "
  end
  local header = "|" .. table.concat(header_parts, "|") .. "|"

  -- Build rows
  local output = { separator, header, separator }
  for _, row in ipairs(rows) do
    local row_parts = {}
    for i, val in ipairs(row) do
      local s = format_value(val)
      if #s > widths[i] then
        s = s:sub(1, widths[i] - 1) .. "…"
      end
      row_parts[i] = " " .. s .. string.rep(" ", widths[i] - #s) .. " "
    end
    table.insert(output, "|" .. table.concat(row_parts, "|") .. "|")
  end
  table.insert(output, separator)

  return output
end

--- Format a short summary string
---@param result table The result from the server
---@return string
function M.summary(result)
  if result.type == "rows" then
    local msg = string.format("%d row%s", result.row_count, result.row_count == 1 and "" or "s")
    if result.truncated then
      msg = msg .. " (truncated)"
    end
    msg = msg .. string.format(" in %dms", result.elapsed_ms)
    return msg
  elseif result.type == "affected" then
    return string.format("%d row%s affected in %dms",
      result.affected_rows,
      result.affected_rows == 1 and "" or "s",
      result.elapsed_ms)
  else
    return ""
  end
end

return M
