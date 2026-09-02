-- Clipboard for sessions whose yanks need to reach another machine.
--
-- Only SSH sessions qualify now: when nvim runs on this Mac over SSH there is
-- no local pasteboard worth reaching, so copy and paste both go over OSC 52
-- and the terminal on the far end answers. Outside SSH, nvim's own clipboard
-- handling (pbcopy/pbpaste) is already correct and this does nothing.
--
-- The Linux version also handled tmux and herdr, and preferred wl-copy for
-- paste; both multiplexers were dropped in the macOS port.
local M = {}

function M.setup()
  local in_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil

  if not in_ssh then
    return
  end

  local osc52 = require("vim.ui.clipboard.osc52")

  vim.g.clipboard = {
    name = "RemoteClipboard",
    -- macOS has one pasteboard; there is no X11/Wayland primary selection, so
    -- "*" and "+" both map to it.
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
    cache_enabled = 0,
  }
end

return M
