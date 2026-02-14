# pond.nvim

Run database queries from inside Neovim. Write SQL in your buffer, execute it with a keybind, see results inline or in a floating window.

## Features

- Run SQL queries without leaving your editor
- Results displayed as virtual text or in a floating window
- Supports PostgreSQL (`psql`), MySQL (`mysql`), and SQLite (`sqlite3`)
- Reads connection strings from `.env` files
- Async execution — non-blocking, cancellable queries
- Detects SQL in fenced code blocks, comments, and `.sql` files

## Requirements

- Neovim 0.9+
- One or more database CLI tools: `psql`, `mysql`, or `sqlite3`
- A `.env` file with your `DATABASE_URL` (or per-setup config)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "yourusername/pond.nvim",
  config = function()
    require("pond").setup()
  end,
}
```

## Usage

1. Place your cursor inside a SQL query (fenced block, comment, or `.sql` file)
2. Run `:Pond`
3. Results appear as virtual text below the query, or in a float for larger result sets

## How It Works

1. Detects SQL query boundaries under the cursor
2. Reads `DATABASE_URL` from the nearest `.env` file to determine the connection and DB type
3. Shells out to the appropriate CLI tool (`psql`, `mysql`, `sqlite3`)
4. Parses the tabular output and displays it in the editor
