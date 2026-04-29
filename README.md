# 🪻 Lilac

> _"Make anywhere feel like yours. Just let it unfold."_

A Swift-based CLI for managing and backing up your dotfiles. It helps you collect the configs you care about and sync them across your machines, structured exactly the way you want.

> [!WARNING]
> This project is intended for study purposes only.  
> It follows a course-defined scope and focuses on a limited set of features.  
> Due to the submission deadline on **March 5, 2026**, some parts may be incomplete or experimental.  
> There may be more complete or optimal approaches outside this scope.

## Inspiration

Lilac is inspired by the approach of [chezmoi](https://chezmoi.io), a well-established dotfile management tool.

## Prerequisites

- **Swift 6.2+**
- **macOS 15+**

### Running the project

1. Clone the repository

```bash
git clone https://github.com/staciax/lilac-v0.git
```

2. Build the package

```bash
swift build
```

## Quick Start

```bash
# init your dotfiles repository at ~/.local/share/lilac
lilac init

# add configs using presets
lilac add -p vscode
lilac add -p ssh

# add custom files or directories manually
lilac add ~/.vimrc
lilac add ~/my-scripts
```

## Configuration

Lilac uses TOML files for configuration. It's split into a global config and modular presets.

- **Global Config**: Located at `~/.config/lilac/lilac.toml`

```toml
source-dir = "~/.local/share/lilac"

[filters]
exclude = [".DS_Store", ".git", "*.backup", "node_modules"]
```

- **Presets**: Located at `~/.config/lilac/presets/*.toml`

```toml
# presets/code.toml
name = "Visual Studio Code"
aliases = ["vscode"]

[paths]
macOS = "~/Library/Application Support/Code/User"
linux = "~/.config/Code/User"

[filters]
include = [
    "settings.json",
    "keybindings.json",
    "snippets/**",
]
exclude = [
    "**/globalStorage",
    "**/workspaceStorage",
]
```

## Links

- https://www.hackingwithswift.com/guide/ios-swiftui/5/2/key-points
- https://developer.apple.com/documentation/xcode/running-code-on-a-specific-version

## License & Copyright

This repository is a prototype developed for an academic project.

**All rights reserved.**

No permission is granted to use, copy, modify, or distribute this source code, in whole or in part, without explicit prior written consent.

This repository is provided for viewing and educational purposes only. It is not intended for production use.
