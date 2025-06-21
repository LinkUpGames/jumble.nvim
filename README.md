# 🔀 Jumble.nvim

Say goodbye to tedious manual theme changes! With this plugin, your theme will automatically update to a random theme at a specified time interval.

- **Choose Your interval**: Set how often you want your theme to refresh (e.g., every day, every other week)

- **Random Themes**: Set your theme randomly after the set time interval. Choose from a list of themes you provide or from all the themes installed

![example](https://github.com/user-attachments/assets/418c4550-4caf-462a-b145-c50a251f5d02)

## 🚀 Features
**Customizable Intervals**: Choose from daily, weekly, monthly, or even yearly intervals to randomize your theme

## ⚡ Requirements
- Neovim >= 0.10.0

## 📦 Installation
Install the plugin using your preferred package manager
```lua
-- lazy.nvim
return {
  "LinkUpGames/jumble.nvim",
  opts = { }
}
```

```lua
-- Manual setup
require("jumble").setup()
```

## ⚙️ Configuration
`jumble.nvim` comes with the following defaults:

**Defaults** 
```lua
---@class opts
---@field days number The number of days before the new theme rolls over
---@field months number The number of months before the new theme rolls over
---@field years number The number of years before the new theme rolls over
---@field hours number The number of hours before the new theme rolls over
---@field themes table<string> The themes to include for randomizing (empty will default to all themes)
return {
  "LinkUpGames/jumble.nvim",
  opts = {
    days = 1,
    months = 0,
    years = 0,
    hours = 0,
    themes = {}
  }
}
```

**Example** 

```lua
-- Example setup
return {
  "LinkUpGames/jumble.nvim",
  opts = {
    days = 2, -- switches to a random theme every 2 days
    themes = { -- Will randomly pick from these three themes
      "tokyonight",
      "eldritch",
      "catppuccin"
    }
  }
}
```

### 🤖 Commands
All commands start with `Jumble`. For example, you can call the command `Jumble randomize` to randomize the theme to a new one.

| Command | Action |
| --------------- | --------------- |
| `randomize` | Force a new random theme. Note that this will also update the next time the plugin will randomly pick another theme |


## 🤝 Contributions
If you find any bugs or issues, you are more than welcome to open a pull request or leave an issue ticket and I'll check it out!

## ⭐ Inspo
- [colorscheme-randomizer.nvim](https://github.com/jay-babu/colorscheme-randomizer.nvim) 
