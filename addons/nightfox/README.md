# Nightfox Themes

Applies the [Nightfox](https://github.com/EdenEast/nightfox.nvim) palette family to the
Godot editor — both the UI chrome and the script editor syntax colors.

## Use

1. Enable the plugin: **Project → Project Settings → Plugins → Nightfox Themes**.
2. Pick a variant: **Project → Tools → Nightfox Theme → ⟨variant⟩**.

Godot's editor settings are **global**, so applying a variant here themes every project you
open. You only need this addon installed in one project.

Variants: `nightfox` `duskfox` `nordfox` `terafox` `carbonfox` (dark), `dayfox` `dawnfox` (light).

## What it changes

| Setting | Effect |
| --- | --- |
| `interface/theme/base_color`, `accent_color`, `contrast`, `icon_saturation`, `icon_and_font_color` | Editor UI chrome |
| `text_editor/theme/highlighting/*` (49 keys) | Script editor syntax |

Both `interface/theme/color_preset` and `text_editor/theme/color_theme` are set to `Custom`
so the editor does not overwrite the applied values.

## Using the themes without the plugin

**Tools → Nightfox Theme → Install theme files for the Color Theme menu** writes the seven
`.tet` files into Godot's theme folder, so they appear under **Editor Settings → Text Editor
→ Theme → Color Theme**. You can then disable this plugin and keep the syntax themes.

**Remove installed theme files** deletes just those seven files, leaving any other themes
you have alone.

## Reverting

Set **Editor Settings → Interface → Theme → Preset** back to `Default`, and
**Text Editor → Theme → Color Theme** back to `Default`.

## Scripting it

```gdscript
var plugin := EditorInterface.get_editor_plugin("Nightfox Themes")
plugin.apply("duskfox")
```

## License

MIT. Palette by [EdenEast](https://github.com/EdenEast/nightfox.nvim).
