local M = {}

local sql_keywords = {
  "SELECT", "INSERT", "UPDATE", "DELETE", "CREATE", "DROP", "ALTER",
  "WITH", "PRAGMA", "EXPLAIN", "BEGIN", "COMMIT", "ROLLBACK",
}

--- Check if a line looks like it contains SQL
---@param line string
---@return boolean
local function line_has_sql(line)
  local upper = line:upper():gsub("^%s+", "")
  for _, kw in ipairs(sql_keywords) do
    if upper:match("^" .. kw .. "%s") or upper:match("^" .. kw .. "$") or upper:match("^" .. kw .. ";") then
      return true
    end
  end
  return false
end

--- Strategy 1: .sql files — return visual selection or entire buffer
---@param bufnr number
---@param visual_start number|nil
---@param visual_end number|nil
---@return string|nil, number|nil, number|nil
local function extract_sql_file(bufnr, visual_start, visual_end)
  local ft = vim.bo[bufnr].filetype
  local name = vim.api.nvim_buf_get_name(bufnr)
  if ft ~= "sql" and not name:match("%.sql$") then
    return nil, nil, nil
  end

  local start_row, end_row
  if visual_start and visual_end then
    start_row = visual_start
    end_row = visual_end
  else
    start_row = 1
    end_row = vim.api.nvim_buf_line_count(bufnr)
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row - 1, end_row, false)
  local text = table.concat(lines, "\n")
  if text:match("%S") then
    return text, start_row, end_row
  end
  return nil, nil, nil
end

--- Strategy 2: fenced ```sql blocks in markdown etc
---@param bufnr number
---@param cursor_row number
---@return string|nil, number|nil, number|nil
local function extract_fenced_block(bufnr, cursor_row)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local fence_start, fence_end

  -- Walk backward from cursor to find opening fence
  for i = cursor_row, 1, -1 do
    if lines[i]:match("^```sql") then
      fence_start = i
      break
    end
    -- If we hit a closing fence before an opening one, we're not in a block
    if lines[i]:match("^```$") and i < cursor_row then
      break
    end
  end

  if not fence_start then
    return nil, nil, nil
  end

  -- Walk forward from cursor to find closing fence
  for i = cursor_row, #lines do
    if lines[i]:match("^```$") and i > fence_start then
      fence_end = i
      break
    end
  end

  if not fence_end then
    return nil, nil, nil
  end

  -- Extract lines between fences (exclusive)
  local sql_lines = {}
  for i = fence_start + 1, fence_end - 1 do
    table.insert(sql_lines, lines[i])
  end

  local text = table.concat(sql_lines, "\n")
  if text:match("%S") then
    return text, fence_start + 1, fence_end - 1
  end
  return nil, nil, nil
end

--- Strategy 3: contiguous SQL lines around cursor (comment blocks)
---@param bufnr number
---@param cursor_row number
---@return string|nil, number|nil, number|nil
local function extract_sql_block(bufnr, cursor_row)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Check if cursor line has SQL
  if not lines[cursor_row] or not line_has_sql(lines[cursor_row]) then
    -- Allow cursor to be on a non-keyword line within a SQL block
    -- Check nearby lines
    local found = false
    for offset = -2, 2 do
      local row = cursor_row + offset
      if row >= 1 and row <= #lines and line_has_sql(lines[row]) then
        found = true
        break
      end
    end
    if not found then
      return nil, nil, nil
    end
  end

  -- Walk backward to find start of SQL block
  local start_row = cursor_row
  for i = cursor_row - 1, 1, -1 do
    local line = lines[i]
    if line:match("^%s*$") then
      break
    end
    start_row = i
  end

  -- Walk forward to find end of SQL block
  local end_row = cursor_row
  for i = cursor_row + 1, #lines do
    local line = lines[i]
    if line:match("^%s*$") then
      break
    end
    end_row = i
  end

  local sql_lines = {}
  for i = start_row, end_row do
    -- Strip leading comment markers (-- or //)
    local line = lines[i]:gsub("^%s*%-%-+%s?", ""):gsub("^%s*//%s?", "")
    table.insert(sql_lines, line)
  end

  local text = table.concat(sql_lines, "\n")
  if text:match("%S") then
    return text, start_row, end_row
  end
  return nil, nil, nil
end

--- Extract SQL under cursor
---@param bufnr number|nil Buffer number (default: current)
---@param visual_start number|nil Visual selection start row (1-indexed)
---@param visual_end number|nil Visual selection end row (1-indexed)
---@return string|nil sql_text
---@return number|nil start_row (1-indexed)
---@return number|nil end_row (1-indexed)
function M.get_sql(bufnr, visual_start, visual_end)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]

  -- Strategy 1: .sql files
  local text, s, e = extract_sql_file(bufnr, visual_start, visual_end)
  if text then return text, s, e end

  -- Strategy 2: fenced blocks
  text, s, e = extract_fenced_block(bufnr, cursor_row)
  if text then return text, s, e end

  -- Strategy 3: contiguous SQL lines
  text, s, e = extract_sql_block(bufnr, cursor_row)
  if text then return text, s, e end

  return nil, nil, nil
end

return M
