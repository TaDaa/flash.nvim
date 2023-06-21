local State = require("flash.state")
local Util = require("flash.util")

local M = {}

function M.show()
  local state = State.new({
    search = { multi_window = true, wrap = true },
    highlight = { backdrop = true, label = { current = true } },
    matcher = function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      ---@param diag Diagnostic
      return vim.tbl_map(function(diag)
        return {
          pos = { diag.lnum + 1, diag.col },
          end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
        }
      end, vim.diagnostic.get(buf))
    end,
  })

  local pos = vim.api.nvim_win_get_cursor(0)

  local char = Util.get_char()
  if char then
    local match = state:find({ label = char })
    if match then
      vim.api.nvim_win_call(match.win, function()
        vim.api.nvim_win_set_cursor(match.win, match.pos)
        vim.diagnostic.open_float()
        vim.api.nvim_win_set_cursor(match.win, pos)
      end)
    else
      vim.api.nvim_input(char)
    end
    state:hide()
  end
end

return M
