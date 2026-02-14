local extract = require("pond.extract")
local connection = require("pond.connection")
local process = require("pond.process")
local display = require("pond.display")

local M = {}

local config = {}
local current_conn_id = nil

--- Setup pond.nvim
---@param opts table|nil
function M.setup(opts)
  config = opts or {}

  vim.api.nvim_create_user_command("Pond", function(cmd)
    M.run(cmd)
  end, { range = true })

  vim.api.nvim_create_user_command("PondConnect", function()
    M.connect()
  end, {})

  vim.api.nvim_create_user_command("PondDisconnect", function()
    M.disconnect()
  end, {})

  vim.api.nvim_create_user_command("PondStop", function()
    M.stop()
  end, {})
end

--- Connect to database
---@param opts table|nil Override backend/connection_string
function M.connect(opts)
  opts = opts or {}
  local backend, conn_str

  if opts.backend and opts.connection_string then
    backend = opts.backend
    conn_str = opts.connection_string
  else
    backend, conn_str = connection.resolve(config)
  end

  if not backend or not conn_str then
    vim.notify("[pond] no DATABASE_URL found. Set it in .env or pass to setup()", vim.log.levels.ERROR)
    return
  end

  if not process.start() then return end

  process.send("connect", {
    backend = backend,
    connection_string = conn_str,
  }, function(resp)
    if resp.error then
      vim.notify("[pond] connect failed: " .. resp.error.message, vim.log.levels.ERROR)
      return
    end
    current_conn_id = resp.result.connection_id
    vim.notify("[pond] connected (" .. current_conn_id .. ")", vim.log.levels.INFO)
  end)
end

--- Run SQL query under cursor
---@param cmd table|nil Command info from nvim (for range)
function M.run(cmd)
  local bufnr = vim.api.nvim_get_current_buf()

  local visual_start, visual_end
  if cmd and cmd.range == 2 then
    visual_start = cmd.line1
    visual_end = cmd.line2
  end

  local sql, start_row, end_row = extract.get_sql(bufnr, visual_start, visual_end)
  if not sql then
    vim.notify("[pond] no SQL found under cursor", vim.log.levels.WARN)
    return
  end

  -- Auto-connect if needed
  if not current_conn_id then
    local backend, conn_str = connection.resolve(config)
    if not backend then
      vim.notify("[pond] no DATABASE_URL found", vim.log.levels.ERROR)
      return
    end

    if not process.start() then return end

    process.send("connect", {
      backend = backend,
      connection_string = conn_str,
    }, function(resp)
      if resp.error then
        vim.notify("[pond] connect failed: " .. resp.error.message, vim.log.levels.ERROR)
        return
      end
      current_conn_id = resp.result.connection_id
      M._execute(bufnr, sql, end_row)
    end)
    return
  end

  M._execute(bufnr, sql, end_row)
end

--- Execute a query (internal)
---@param bufnr number
---@param sql string
---@param end_row number
function M._execute(bufnr, sql, end_row)
  if not current_conn_id then
    vim.notify("[pond] not connected", vim.log.levels.ERROR)
    return
  end

  process.send("execute", {
    sql = sql,
    connection_id = current_conn_id,
  }, function(resp)
    if resp.error then
      vim.notify("[pond] query error: " .. resp.error.message, vim.log.levels.ERROR)
      return
    end
    display.show(bufnr, end_row, resp.result, config.inline_threshold)
  end)
end

--- Disconnect from database
function M.disconnect()
  if not current_conn_id then
    vim.notify("[pond] not connected", vim.log.levels.WARN)
    return
  end

  process.send("disconnect", {
    connection_id = current_conn_id,
  }, function(resp)
    if resp.error then
      vim.notify("[pond] disconnect failed: " .. resp.error.message, vim.log.levels.ERROR)
      return
    end
    vim.notify("[pond] disconnected", vim.log.levels.INFO)
    current_conn_id = nil
  end)
end

--- Stop the server
function M.stop()
  process.stop()
  current_conn_id = nil
  vim.notify("[pond] server stopped", vim.log.levels.INFO)
end

return M
