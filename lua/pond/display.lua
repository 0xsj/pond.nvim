local format = require("pond.format")

local M = {}

local ns = vim.api.nvim_create_namespace("pond")
local float_win = nil
local float_buf = nil

--- Clear previous pond results from a buffer
---@param bufnr number
function M.clear(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

--- Display results as virtual text below end_row
---@param bufnr number
---@param end_row number (1-indexed)
---@param result table Server result
function M.show_inline(bufnr, end_row, result)
  M.clear(bufnr)

  if result.type == "affected" then
    local summary = format.summary(result)
    vim.api.nvim_buf_set_extmark(bufnr, ns, end_row - 1, 0, {
      virt_lines = { { { summary, "Comment" } } },
      virt_lines_above = false,
    })
    return
  end

  if result.type ~= "rows" then return end

  local lines = format.ascii_table(result.columns, result.rows)
  local summary = format.summary(result)
  table.insert(lines, summary)

  local virt_lines = {}
  for _, line in ipairs(lines) do
    table.insert(virt_lines, { { line, "Comment" } })
  end

  vim.api.nvim_buf_set_extmark(bufnr, ns, end_row - 1, 0, {
    virt_lines = virt_lines,
    virt_lines_above = false,
  })
end

--- Display results in a floating window
---@param result table Server result
function M.show_float(result)
  -- Close existing float
  M.close_float()

  local lines = {}
  if result.type == "rows" then
    lines = format.ascii_table(result.columns, result.rows)
    table.insert(lines, "")
    table.insert(lines, format.summary(result))
  elseif result.type == "affected" then
    table.insert(lines, format.summary(result))
  end

  if #lines == 0 then return end

  -- Calculate dimensions
  local max_width = 0
  for _, line in ipairs(lines) do
    if #line > max_width then max_width = #line end
  end
  local width = math.min(max_width, math.floor(vim.o.columns * 0.8))
  local height = math.min(#lines, math.floor(vim.o.lines * 0.6))

  float_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
  vim.bo[float_buf].modifiable = false
  vim.bo[float_buf].bufhidden = "wipe"

  float_win = vim.api.nvim_open_win(float_buf, true, {
    relative = "editor",
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Pond Results ",
    title_pos = "center",
  })

  -- Close with q or Escape
  local close_keys = { "q", "<Esc>" }
  for _, key in ipairs(close_keys) do
    vim.keymap.set("n", key, function()
      M.close_float()
    end, { buffer = float_buf, nowait = true })
  end
end

--- Close the floating window
function M.close_float()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, true)
  end
  float_win = nil
  float_buf = nil
end

--- Display results — choose inline vs float based on row count
---@param bufnr number
---@param end_row number (1-indexed)
---@param result table Server result
---@param threshold number|nil Max rows for inline display (default 5)
function M.show(bufnr, end_row, result, threshold)
  threshold = threshold or 5

  if result.type == "rows" and result.row_count > threshold then
    M.show_float(result)
  else
    M.show_inline(bufnr, end_row, result)
  end
end

return M
