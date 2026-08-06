# Black Atom Industries

<h3 align="center">Elegant, cohesive themes for your development ecosystem</h3>

<p align="center">
  <a href="https://github.com/orgs/black-atom-industries/repositories">View All Repositories</a>
</p>

## Development Status

<p align="center">
  <strong>Currently in active development toward 1.0 release</strong>
</p>

- All themes are usable but may undergo breaking changes until 1.0
- Core system being refined for better consistency across platforms
- Tracking progress in our [GitHub Projects](https://github.com/orgs/black-atom-industries/projects)
- Feel free to use, but be prepared for potential breaking changes

## Theme Collections

Black Atom includes multiple theme collections, each with its own distinctive style and aesthetic philosophy:

| Collection   | Description                                                          |
| ------------ | -------------------------------------------------------------------- |
| **Default**  | Core default themes across light and dark variants                   |
| **JPN**      | Japanese-inspired themes capturing traditional aesthetics            |
| **Stations** | Space station-inspired themes for different operational environments |
| **Terra**    | Earth's seasonal cycles captured in day and night variants           |
| **MNML**     | Minimalist themes focused on clean, distraction-free environments    |
| **Paper**    | Paper-inspired themes with tactile light and dark variants           |

Browse individual themes in the [core repository](https://github.com/black-atom-industries/core).

## Architecture

Black Atom uses an adapter pattern to maintain themes across platforms:

1. **[Core](https://github.com/black-atom-industries/core)** - Single source of truth for all theme definitions, published on [JSR](https://jsr.io/@black-atom/core)
2. **Adapters** - Platform-specific implementations that transform core definitions into native theme formats
3. **Templates** - Adapters use the [Eta](https://eta.js.org/) template engine to generate platform-specific files from core definitions

## Supported Platforms

| Platform | Adapter                                                                             |
| -------- | ----------------------------------------------------------------------------------- |
| Ghostty  | [black-atom-industries/ghostty](https://github.com/black-atom-industries/ghostty)   |
| Helm     | [black-atom-industries/helm](https://github.com/black-atom-industries/helm)         |
| Herdr    | [black-atom-industries/herdr](https://github.com/black-atom-industries/herdr)       |
| Lazygit  | [black-atom-industries/lazygit](https://github.com/black-atom-industries/lazygit)   |
| Niri     | [black-atom-industries/niri](https://github.com/black-atom-industries/niri)         |
| Neovim   | [black-atom-industries/nvim](https://github.com/black-atom-industries/nvim)         |
| Obsidian | [black-atom-industries/obsidian](https://github.com/black-atom-industries/obsidian) |
| tmux     | [black-atom-industries/tmux](https://github.com/black-atom-industries/tmux)         |
| Waybar   | [black-atom-industries/waybar](https://github.com/black-atom-industries/waybar)     |
| WezTerm  | [black-atom-industries/wezterm](https://github.com/black-atom-industries/wezterm)   |
| Zed      | [black-atom-industries/zed](https://github.com/black-atom-industries/zed)           |

## Get Started

1. Browse our [repositories](https://github.com/orgs/black-atom-industries/repositories)
2. Choose your platform
3. Follow the installation instructions
4. Enjoy a consistent theme experience across your development environment

<div align="center">
  <p>Made with care by <a href="https://github.com/nikbrunner">nikbrunner</a></p>
</div>
