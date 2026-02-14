local M = {}

--- Parse a .env file and return key-value pairs
---@param path string
---@return table<string, string>
local function parse_env_file(path)
  local env = {}
  local f = io.open(path, "r")
  if not f then return env end

  for line in f:lines() do
    -- Skip comments and empty lines
    if not line:match("^%s*#") and line:match("%S") then
      local key, val = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
      if key and val then
        -- Strip surrounding quotes
        val = val:gsub("^[\"'](.-)[\"']$", "%1")
        env[key] = val
      end
    end
  end

  f:close()
  return env
end

--- Walk up from dir looking for a .env file containing DATABASE_URL
---@param start_dir string
---@return string|nil url
local function find_database_url(start_dir)
  local dir = start_dir
  local prev = nil
  while dir and dir ~= prev do
    local env_path = dir .. "/.env"
    local env = parse_env_file(env_path)
    if env.DATABASE_URL then
      return env.DATABASE_URL
    end
    prev = dir
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

--- Parse a DATABASE_URL into backend + connection_string
---@param url string
---@return string|nil backend
---@return string|nil connection_string
function M.parse_url(url)
  if not url then return nil, nil end

  -- sqlite:/path or sqlite:///path or sqlite::memory:
  if url:match("^sqlite:") then
    local path = url:gsub("^sqlite:", "")
    -- Handle sqlite:///path
    path = path:gsub("^//", "")
    if path == "" then
      return nil, nil
    end
    return "sqlite", path
  end

  -- postgresql:// or postgres://
  if url:match("^postgre") then
    return "postgresql", url
  end

  -- mysql://
  if url:match("^mysql:") then
    return "mysql", url
  end

  return nil, nil
end

--- Resolve the database connection for the current buffer
---@param config table|nil Plugin config with optional database_url
---@return string|nil backend
---@return string|nil connection_string
function M.resolve(config)
  config = config or {}

  -- 1. Explicit config override
  if config.database_url then
    return M.parse_url(config.database_url)
  end

  -- 2. Environment variable
  local env_url = os.getenv("DATABASE_URL")
  if env_url then
    return M.parse_url(env_url)
  end

  -- 3. Walk up looking for .env
  local buf_dir = vim.fn.expand("%:p:h")
  local url = find_database_url(buf_dir)
  if url then
    return M.parse_url(url)
  end

  return nil, nil
end

return M
