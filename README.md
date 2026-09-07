# Nightfox for Godot

The [Nightfox](https://github.com/EdenEast/nightfox.nvim) palette for the Godot editor,
covering the UI and the script editor.

Seven variants: `nightfox`, `duskfox`, `nordfox`, `terafox`, `carbonfox`, and the light
`dayfox` and `dawnfox`. Tested on Godot 4.7.1.

## Install

Download the repo zip, then in Godot:

1. AssetLib → Import, pick the zip, tick **Ignore asset root**, Install.
2. Project Settings → Plugins → enable Nightfox Themes.
3. Tools → Nightfox Theme → pick a variant.

Ignoring the asset root matters. Godot only finds plugins in `res://addons/`, so the addon
has to land there rather than a folder deeper.

Copying `addons/nightfox/` into your project by hand works just as well; start at step 2.

Editor settings are global, so you only do this once. Applying a variant in one project
themes every project you open.

## Keeping the themes without the plugin

Tools → Nightfox Theme → Install theme files copies the seven `.tet` files into Godot's theme
folder, where they appear under Editor Settings → Text Editor → Theme → Color Theme. You can
disable the plugin afterwards and keep the syntax colors. Remove installed theme files undoes
it.

Worth doing: `.tet` files survive engine upgrades, while editor settings are tied to the
version series, so a fresh install of a new series needs the UI colors re-applying.

## Regenerating the themes

`generator/godot.lua` is a Nightfox `extra` generator that produces the `.tet` files in
`addons/nightfox/themes/`.

```sh
git clone https://github.com/EdenEast/nightfox.nvim && cd nightfox.nvim
cp ../generator/godot.lua lua/nightfox/extra/godot.lua
# add to the `extras` table in misc/extra.lua:
#   godot = { ext = "tet", use_spec_name = true },
nvim --headless --clean -u misc/extra.lua
cp extra/*/*.tet ../addons/nightfox/themes/
```

This repo is itself a Godot project, so you can enable the addon here and test in place.
`demo.gd` is a syntax specimen covering all 49 color keys.

## Limits

Godot generates its UI from a base color, an accent and a contrast value rather than a full
color file, so the UI is a close match, not an exact port. The script editor is exact: all 49
keys are set.

## Credits

Palette by [EdenEast](https://github.com/EdenEast/nightfox.nvim), MIT. Port MIT.
