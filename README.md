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

Copy `addons/nightfox/` into any one project's `addons/` folder, then:

1. **Project → Project Settings → Plugins** → enable **Nightfox Themes**
2. **Project → Tools → Nightfox Theme → ⟨variant⟩**

That's it. The plugin sets the editor's base color, accent, contrast and icon settings *and*
all 49 syntax colors directly — no files to copy, nothing to restart.

Because editor settings are global, one project is enough for every project.

### Optional: the Color Theme dropdown

If you'd rather have the themes listed under **Editor Settings → Text Editor → Theme →
Color Theme** — useful if you want to keep the themes but *not* keep the plugin enabled —
use **Tools → Nightfox Theme → Install theme files for the Color Theme menu**. That writes
the seven `.tet` files into Godot's theme folder (resolved per-platform via `EditorPaths`),
and **Remove installed theme files** takes them out again.

You can then disable the plugin; the syntax themes stay.

## Repo layout

| Path | What it is |
| --- | --- |
| `addons/nightfox/` | The distributable addon — this is the only folder users need. |
| `addons/nightfox/themes/*.tet` | The seven generated syntax themes (canonical copy). |
| `generator/godot.lua` | Nightfox `extra` generator that produces those `.tet` files. |
| `demo.gd` | Syntax specimen exercising all 49 color keys, each labelled. |
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

## Publishing

See [PACKAGING.md](PACKAGING.md) for the Asset Library submission checklist and the
upstream nightfox.nvim PR.

## Known limits

Godot's editor **UI** is not fully themeable by a color file — the chrome is generated
procedurally from a base color, an accent and a contrast value. The addon sets those to match
each variant, which gets close but is not a pixel-exact port. The **script editor** is fully
themeable; all 49 keys are set exactly.

## Credits

Palette by [EdenEast](https://github.com/EdenEast/nightfox.nvim), MIT. Port MIT.
