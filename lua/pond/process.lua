local M = {}

local job_id = nil
local pending = {}
local req_counter = 0
local stdout_buffer = ""

--- Find the pond-server binary relative to this plugin's directory
---@return string|nil
local function find_binary()
  local info = debug.getinfo(1, "S")
  local script_path = info.source:gsub("^@", "")
  -- script_path is lua/pond/process.lua, go up to plugin root
  local plugin_root = vim.fn.fnamemodify(script_path, ":h:h:h")
  local binary = plugin_root .. "/server/target/release/pond-server"

  if vim.fn.executable(binary) == 1 then
    return binary
  end

  -- Try debug build
  binary = plugin_root .. "/server/target/debug/pond-server"
  if vim.fn.executable(binary) == 1 then
    return binary
  end

  return nil
end

--- Handle a complete JSON line from stdout
---@param line string
local function handle_line(line)
  if line == "" then return end

  local ok, resp = pcall(vim.json.decode, line)
  if not ok then
    vim.schedule(function()
      vim.notify("[pond] invalid JSON from server: " .. line, vim.log.levels.ERROR)
    end)
    return
  end

  local id = resp.id
  if id and pending[id] then
    local callback = pending[id]
    pending[id] = nil
    vim.schedule(function()
      callback(resp)
    end)
  end
end

--- Process raw stdout data
---@param data string[]
local function on_stdout(_, data, _)
  if not data then return end
  for _, chunk in ipairs(data) do
    stdout_buffer = stdout_buffer .. chunk
    while true do
      local nl = stdout_buffer:find("\n")
      if not nl then break end
      local line = stdout_buffer:sub(1, nl - 1)
      stdout_buffer = stdout_buffer:sub(nl + 1)
      handle_line(line)
    end
  end
end

local function on_exit(_, code, _)
  job_id = nil
  pending = {}
  stdout_buffer = ""
  if code ~= 0 then
    vim.schedule(function()
      vim.notify("[pond] server exited with code " .. code, vim.log.levels.WARN)
    end)
  end
end

--- Start the pond-server process
---@return boolean success
function M.start()
  if job_id then return true end

  local binary = find_binary()
  if not binary then
    vim.notify("[pond] pond-server binary not found. Run: cd server && cargo build --release", vim.log.levels.ERROR)
    return false
  end

  job_id = vim.fn.jobstart({ binary }, {
    on_stdout = on_stdout,
    on_exit = on_exit,
    stdout_buffered = false,
  })

  if job_id <= 0 then
    vim.notify("[pond] failed to start pond-server", vim.log.levels.ERROR)
    job_id = nil
    return false
  end

  return true
end

--- Stop the pond-server process
function M.stop()
  if not job_id then return end
  -- Send shutdown command
  M.send("shutdown", {}, function(_) end)
  -- Give it a moment then force kill
  vim.defer_fn(function()
    if job_id then
      vim.fn.jobstop(job_id)
      job_id = nil
    end
  end, 500)
end

--- Send a request to the server
---@param method string
---@param params table
---@param callback function(response: table)
---@return string request_id
function M.send(method, params, callback)
  if not job_id then
    vim.schedule(function()
      callback({ error = { code = "not_running", message = "pond-server is not running" } })
    end)
    return ""
  end

  req_counter = req_counter + 1
  local id = "req_" .. req_counter

  local request = vim.json.encode({
    id = id,
    method = method,
    params = params or {},
  })

  pending[id] = callback
  vim.fn.chansend(job_id, request .. "\n")

  return id
end

--- Check if the server is running
---@return boolean
function M.is_running()
  return job_id ~= nil
end

return M
