# Nightfox for Godot

The [Nightfox](https://github.com/EdenEast/nightfox.nvim) theme family for the Godot editor —
UI chrome and script editor, seven variants.

Verified against **Godot 4.7.1**.

`nightfox` · `duskfox` · `nordfox` · `terafox` · `carbonfox` — `dayfox` · `dawnfox`

## Setup

Download the repo zip (**Code → Download ZIP**, or a release's *Source code (zip)*), then
in the project you want it in:

1. **AssetLib → Import…** → pick the zip → **Install**
2. **Project → Project Settings → Plugins** → enable **Nightfox Themes**
3. **Project → Tools → Nightfox Theme → ⟨variant⟩**

The zip contains only `addons/nightfox/`, so the installer has nothing to overwrite. Or copy
the folder in by hand and skip to step 2:

```sh
git clone <this-repo> gdtheme
cp -r gdtheme/addons/nightfox /path/to/your/project/addons/
```

That's it. The plugin sets the editor's base color, accent, contrast and icon settings *and*
all 49 syntax colors directly — no files to copy, nothing to restart.

No project handy? `git clone` the repo and open `gdtheme/` itself in Godot — the clone *is* a
project, with the addon already in place. Enable it, apply a variant, done. (The zip has no
`project.godot`; that's deliberate, see below.)

> **You only ever do this once.** Godot's editor settings are global — they live in
> `~/Library/Application Support/Godot/editor_settings-<version>.tres` on macOS,
> `~/.config/godot/` on Linux, `%APPDATA%\Godot\` on Windows — not in your project. So
> applying a variant from *any* project themes *every* project you open.

### Optional: the Color Theme dropdown

To have the themes listed under **Editor Settings → Text Editor → Theme → Color Theme** —
useful if you want to keep the themes but *not* keep the plugin enabled — use
**Tools → Nightfox Theme → Install theme files for the Color Theme menu**. That writes the
seven `.tet` files into Godot's theme folder (resolved per-platform via `EditorPaths`), and
**Remove installed theme files** takes them out again.

You can then disable the plugin and the syntax themes stay.

This is also the most durable option: `.tet` files are version-independent and survive engine
upgrades, while editor settings are keyed to the version series. Upgrading 4.7 → 4.8 migrates
your settings across, but a *fresh* install of a new series starts from defaults — the syntax
colors persist, the UI chrome needs re-applying.

## Repo layout

| Path | What it is |
| --- | --- |
| `addons/nightfox/` | The addon — the only folder you need, and the only one in the zip. |
| `addons/nightfox/themes/*.tet` | The seven generated syntax themes (canonical copy). |
| `generator/godot.lua` | Nightfox `extra` generator that produces those `.tet` files. |
| `demo.gd` | Syntax specimen exercising all 49 color keys, each labelled. |
| `project.godot` | Makes this repo a Godot project, so you can test the addon in place. |

Everything except `addons/nightfox/` is marked `export-ignore` in `.gitattributes`, so it is
present in a clone but absent from every archive GitHub generates. Godot's asset installer
strips the zip's single top-level folder and writes the remainder into `res://` with no
special case for `project.godot` — anything left at archive root would overwrite the target
project's file of that name.

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
