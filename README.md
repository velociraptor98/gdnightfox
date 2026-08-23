# Nightfox for Godot

The [Nightfox](https://github.com/EdenEast/nightfox.nvim) theme family for the Godot editor —
UI chrome and script editor, seven variants.

Verified against **Godot 4.7.1**.

`nightfox` · `duskfox` · `nordfox` · `terafox` · `carbonfox` — `dayfox` · `dawnfox`

> **Godot's editor settings are global.** They live in
> `~/Library/Application Support/Godot/editor_settings-<version>.tres` (macOS), not in your
> project. So you only ever install this **once** — applying a theme from any project themes
> every project you open.

## Install

### Option A — syntax colors only, no plugin

```sh
./install.sh              # copies the .tet files into Godot's theme folder
./install.sh --uninstall  # removes them again
```

Then restart Godot and pick a variant under
**Editor → Editor Settings → Text Editor → Theme → Color Theme**.

Windows (no `sh`): copy `addons/nightfox/themes/*.tet` into `%APPDATA%\Godot\text_editor_themes\`.

### Option B — UI + syntax, via the addon

Copy `addons/nightfox/` into any one project's `addons/` folder, then:

1. **Project → Project Settings → Plugins** → enable **Nightfox Themes**
2. **Project → Tools → Nightfox Theme → ⟨variant⟩**

This sets the editor's base color, accent, contrast and icon settings *and* all 49 syntax
colors in one action.

### Option C — Godot Asset Library

This repo is Asset Library-shaped already (`addons/` at root, `LICENSE`, `.gitignore`, a
plugin-local README and license). To publish, see [PACKAGING.md](PACKAGING.md).

## Repo layout

| Path | What it is |
| --- | --- |
| `addons/nightfox/` | The distributable addon — this is the only folder users need. |
| `addons/nightfox/themes/*.tet` | The seven generated syntax themes (canonical copy). |
| `generator/godot.lua` | Nightfox `extra` generator that produces those `.tet` files. |
| `install.sh` | Installer for the no-plugin route. |
| `demo.gd` | Syntax specimen exercising all 49 color keys, each labelled. |
| `FINDINGS.md` | Why it's built this way, and what Godot does/doesn't allow. |
| `project.godot` | Sandbox project for testing the addon. |

## Regenerating the themes

```sh
git clone https://github.com/EdenEast/nightfox.nvim && cd nightfox.nvim
cp ../generator/godot.lua lua/nightfox/extra/godot.lua
# add to the `extras` table in misc/extra.lua:
#   godot = { ext = "tet", use_spec_name = true },
nvim --headless --clean -u misc/extra.lua
cp extra/*/*.tet ../addons/nightfox/themes/
```

## Known limits

Godot's editor **UI** is not fully themeable by a color file — the chrome is generated
procedurally from a base color, an accent and a contrast value. The addon sets those to match
each variant, which gets close but is not a pixel-exact port. The **script editor** is fully
themeable; all 49 keys are set exactly.

## Credits

Palette by [EdenEast](https://github.com/EdenEast/nightfox.nvim), MIT. Port MIT.
