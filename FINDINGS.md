# How to theme Godot with Nightfox — findings

Investigated August 2026 against Godot 4.7.1 and nightfox.nvim `main`.

## 1. What Godot actually lets you theme

Two independent surfaces, with very different levels of control.

### Script editor — fully themeable ✅

`EditorSettings` exposes **49 color keys** under `text_editor/theme/highlighting/*`
(confirmed by reading a real `editor_settings-4.6.tres`), covering syntax, the completion
popup, gutters, diagnostics, GDScript-specific tokens and comment markers.

These serialize to a **`.tet` file** — a `ConfigFile` with one `[color_theme]` section and
`key="rrggbbaa"` values (no leading `#`):

```ini
[color_theme]

background_color="192330ff"
keyword_color="9d79d6ff"
```

Godot discovers `.tet` files in:

| OS | Path |
| --- | --- |
| Linux | `~/.config/godot/text_editor_themes` |
| macOS | `~/Library/Application Support/Godot/text_editor_themes` |
| Windows | `%APPDATA%\Godot\text_editor_themes` |

### Editor UI — only parametric ⚠️

This is the real constraint. Godot generates editor chrome **procedurally** rather than
reading a color file. The whole UI is derived from a handful of settings:

```
interface/theme/base_color        Color
interface/theme/accent_color      Color
interface/theme/contrast          float   (negative for light themes)
interface/theme/icon_saturation   float
interface/theme/icon_and_font_color  int  (0 auto, 1 dark, 2 light)
interface/theme/custom_theme      path to a .tres Theme
```

So you **cannot** map Nightfox's `bg0..bg4` / `fg0..fg3` onto specific editor panels the way
you can in Neovim. You pick a base and an accent and Godot derives the rest. `custom_theme`
accepts a `.tres` `Theme` resource, but it overrides individual control styleboxes — it is a
hand-authored UI reskin, not a palette swap, and it is brittle across Godot versions.

This is exactly where the [Catppuccin Godot port](https://github.com/catppuccin/godot) stops:
it ships `.tet` files only and tells users to set the base/accent/contrast **by hand**.

## 2. The options

| # | Approach | UI | Syntax | Install | Verdict |
| --- | --- | --- | --- | --- | --- |
| A | Ship `.tet` files only | manual | ✅ exact | copy files | Simplest; what Catppuccin does |
| B | `EditorPlugin` addon | ✅ automatic | ✅ exact | enable plugin | **Recommended** |
| C | Custom `.tres` UI theme | ✅ deep | — | copy + set path | High effort, brittle |

### Option A — generated `.tet` files

Write a generator in Nightfox's own `extra` system so the themes stay in lockstep with
upstream palette changes. The contract is small:

```lua
-- lua/nightfox/extra/godot.lua
function M.generate(spec, opts)  -- returns a string
  return template.parse_template_str(content, colors)
end
```

Register it in the `extras` table in `misc/extra.lua`:

```lua
godot = { ext = "tet", use_spec_name = true },
```

Then `nvim --headless --clean -u misc/extra.lua` writes `extra/<variant>/<variant>.tet`
for every variant. Templates use `${path.to.color}` against the spec, and `spec` exposes
`bg0..bg4`, `fg0..fg3`, `sel0/sel1`, `syntax.*`, `diag.*`, `diff.*`, `git.*` and the raw
`palette`. Godot wants bare `rrggbbaa`, so strip the `#` and append alpha.

**This is implemented** in `generator/godot.lua` and produced the 7 files in `themes/`.

### Option B — an EditorPlugin (recommended)

Since Godot 4.2 a `@tool` script can reach editor settings directly:

```gdscript
var settings := EditorInterface.get_editor_settings()
settings.set_setting("interface/theme/base_color", Color("#192330"))
settings.set_setting("text_editor/theme/highlighting/keyword_color", Color("#9d79d6"))
```

That closes the gap Catppuccin leaves open: the plugin sets the UI parameters *and* the
syntax colors in one action, so there is no manual step.

A neat trick used by the prototype — because `.tet` **is** a `ConfigFile`, the addon parses
the bundled theme files rather than duplicating 49 × 7 colors in GDScript:

```gdscript
var cfg := ConfigFile.new()
cfg.load("res://addons/nightfox/themes/%s.tet" % variant)
for key in cfg.get_section_keys("color_theme"):
    settings.set_setting("text_editor/theme/highlighting/%s" % key, color)
```

One generator feeds both the standalone files and the plugin.

**This is implemented** in `addons/nightfox/`.

### Option C — custom `.tres` UI theme

Only worth it for a pixel-exact reskin. You author a `Theme` resource overriding styleboxes
for editor controls and point `interface/theme/custom_theme` at it. It breaks when Godot
changes its control tree, and it can't be generated from a palette alone. Not recommended
for a colorscheme port.

## 3. Recommendation

Ship **A + B together**: the Nightfox `extra` generator as the single source of truth, the
`.tet` files for people who only want syntax colors, and the addon for one-click UI+syntax.
Then upstream `generator/godot.lua` to nightfox.nvim so Godot joins the other 16 ports.

## 4. Verification performed

- Generated all 7 variants through Nightfox's real headless pipeline — no unresolved
  `${...}` placeholders, all 49 values valid 8-digit hex.
- Diffed every emitted key against the 49 real keys in `editor_settings-4.6.tres` — **zero**
  invalid keys; the only unset ones are the three `comment_markers/*_list` keyword lists,
  which are not colors.
- Compile-checked `plugin.gd` with `Godot --check-only` (and confirmed that check catches a
  deliberately broken script, so the pass is meaningful).
- Ran a headless runtime test parsing all 7 `.tet` files through `ConfigFile` — 7 ok,
  0 failed, colors round-trip correctly (`#192330` → `(0.098, 0.1373, 0.1882)`).

## 5. Gotchas found

- The preset key is `interface/theme/color_preset`, **not** `interface/theme/preset`.
  Set it to `"Custom"` or the editor overwrites your base/accent values.
- Set `text_editor/theme/color_theme` to `"Custom"` for the same reason.
- `interface/theme/icon_and_font_color` describes the **icon and font** color, not the
  theme: `0` Auto, `1` Dark, `2` Light. A *dark* theme needs `2` (light fonts); a *light*
  theme needs `1`. Getting this backwards paints dark text on a dark background and the
  editor becomes unreadable — the base color still looks right, so it is easy to misread
  as a palette problem rather than this one setting.
- Light variants (`dayfox`, `dawnfox`) also need **negative** `contrast` (~-0.16);
  positive contrast makes light themes look wrong.
- `.tet` values have **no** leading `#` and **require** the alpha pair.
- Godot 4.7.1 still reads `editor_settings-4.6.tres` — settings files are keyed to a
  version series, so test against the file your build actually loads.
