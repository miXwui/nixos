local wezterm = require 'wezterm'
local act = wezterm.action

-- https://wezterm.org/config/lua/wezterm.gui/default_key_tables.html
local copy_mode = nil
if wezterm.gui then
  copy_mode = wezterm.gui.default_key_tables().copy_mode
  table.insert(
    copy_mode,
    {
      key = 'LeftArrow',
      mods = 'CTRL',
      action = act.CopyMode 'MoveBackwardWord',
    }
  )
  table.insert(
    copy_mode,
    {
      key = 'RightArrow',
      mods = 'CTRL',
      action = act.CopyMode 'MoveForwardWord',
    }
  )
end

return {
  scrollback_lines = 20000,

  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  window_frame = {
    border_left_width = 0,
    border_right_width = 0,
    border_bottom_height = 0,
    border_top_height = 0,
  },
  window_decorations = "NONE",

  -- disable ligatures
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },

  -- Allows Ctrl+Shift+d to work, etc.
  -- https://wezterm.org/config/key-encoding.html
  enable_csi_u_key_encoding = true,

  keys = {
    {
      key = 'Enter',
      mods = 'ALT',
      action = act.DisableDefaultAssignment,
    },
    -- Fixes swallowing Ctrl+<arrow keys> etc.
    {
      key = 'Backspace',
      mods = 'CTRL',
      action = act.SendKey { key = 'w', mods = 'CTRL' },
    },
    {
      key = 'LeftArrow',
      mods = 'CTRL|SHIFT',
      action = act.DisableDefaultAssignment,
    },
    {
      key = 'RightArrow',
      mods = 'CTRL|SHIFT',
      action = act.DisableDefaultAssignment,
    },
    {
      key = 'UpArrow',
      mods = 'CTRL|SHIFT',
      action = act.DisableDefaultAssignment,
    },
    {
      key = 'DownArrow',
      mods = 'CTRL|SHIFT',
      action = act.DisableDefaultAssignment,
    },
    -- Remap switch panes
    {
      key = 'LeftArrow',
      mods = 'CTRL|ALT',
      action = act.ActivatePaneDirection('Left'),
    },
    {
      key = 'RightArrow',
      mods = 'CTRL|ALT',
      action = act.ActivatePaneDirection('Right'),
    },
    {
      key = 'UpArrow',
      mods = 'CTRL|ALT',
      action = act.ActivatePaneDirection('Up'),
    },
    {
      key = 'DownArrow',
      mods = 'CTRL|ALT',
      action = act.ActivatePaneDirection('Down'),
    },
  },

  -- Copy mode
  -- ```sh
  -- wezterm show-keys --lua --key-table copy_mode
  -- ```
  key_tables = {
    copy_mode = copy_mode
  },
}
