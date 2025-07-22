# locked-in.nvim

A Neovim plugin that tracks how locked in you are during your coding sessions.

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "frosty/locked-in",
  config = function()
    require("locked-in").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "frosty/locked-in",
  config = function()
    require("locked-in").setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'frosty/locked-in'
```

Then add to your config:
```lua
require("locked-in").setup()
```

## Features

- Real-time focus tracking based on your coding activity
- Visual status display with progress bar
- Productivity streak tracking
- Distraction monitoring
- Customizable thresholds and display position

## Commands

- `:LockedIn start` - Start tracking session
- `:LockedIn stop` - End tracking session
- `:LockedIn toggle` - Toggle tracking on/off
- `:LockedIn status` - Show current status
- `:LockedInBoost` - Manually boost focus when you complete something
- `:LockedInDistracted` - Mark a distraction (reduces focus)

## Configuration

```lua
require("locked-in").setup({
  display_position = "topright", -- "topleft", "bottomright", "bottomleft"
  update_interval = 60, -- seconds between automatic updates
  thresholds = {
    locked_in = 80,   -- 80%+ focus score
    focused = 60,     -- 60-79% focus score
    distracted = 40   -- 40-59% focus score
  }
})
```

## How It Works

The plugin automatically tracks your focus based on:
- **File edits**: Productive file types increase your score
- **File switching**: Excessive switching indicates distraction
- **Idle time**: Being idle for >5 minutes reduces score
- **Productivity streaks**: Consistent work boosts your score

Focus levels:
- **LOCKED IN** (80-100%): Peak performance mode
- **Focused** (60-79%): Good concentration
- **Distracted** (40-59%): Losing focus
- **Off Track** (0-39%): Need to refocus

## Requirements

- Neovim 0.7.0+
- Lua support