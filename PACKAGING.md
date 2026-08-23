# Packaging & distribution

Three channels, independent of each other. Pick whichever you actually need — for personal
use across your own machines, channel 1 is enough.

## 0. What "installed" means here

Godot editor settings are **global per engine version**, not per project:

| OS | Settings file |
| --- | --- |
| macOS | `~/Library/Application Support/Godot/editor_settings-<ver>.tres` |
| Linux | `~/.config/godot/editor_settings-<ver>.tres` |
| Windows | `%APPDATA%\Godot\editor_settings-<ver>.tres` |

Consequences worth designing around:

- The addon only needs to exist in **one** project. Keep a small "theme switcher" project
  around, or drop it in whatever project you have open.
- Settings are keyed to the engine **version series**. Upgrading 4.7 → 4.8 migrates settings
  into a new file, and your theme carries over — but a *fresh* install of a new series starts
  from defaults and needs re-applying.
- `.tet` files in `text_editor_themes/` are version-independent and survive upgrades, which
  makes channel 1 the most durable option.

## 1. Git repo (personal / team use)

The repo is already structured for this. To use it on another machine:

```sh
git clone <your-remote> gdtheme && cd gdtheme
./install.sh                       # syntax colors, done
cp -r addons/nightfox /path/to/a/project/addons/   # optional: UI theming too
```

Tag releases so the Asset Library (and humans) have something stable to point at:

```sh
git tag -a v0.1.0 -m "Nightfox for Godot 0.1.0"
git push --tags
```

## 2. Godot Asset Library

The repo already satisfies the structural requirements:

- [x] `addons/nightfox/` at the repo root
- [x] `LICENSE` at root **and** a copy inside the plugin folder (required for plugins —
      users keep only that folder)
- [x] `README.md` at root and inside the plugin folder
- [x] `.gitignore` excluding `.godot/`
- [x] `.gitattributes` marking dev-only files `export-ignore`
- [x] `addons/nightfox/icon.png` — 128×128, square
- [x] No submodules (GitHub's zip would drop them)

Then submit at <https://godotengine.org/asset-library/asset> with:

| Field | Value |
| --- | --- |
| Category | Addon → Tools |
| Godot version | `4.7` (one submission per engine version) |
| Version | `0.1.0` |
| Repository URL | your GitHub URL |
| Issues URL | `<repo>/issues` |
| Download commit | the hash of your tagged release |
| Icon URL | the **raw.githubusercontent.com** link to `icon.png`, not the `github.com` page |
| License | MIT |

Caveats: submissions are human-reviewed, so expect a wait. Listings are per engine version —
supporting 4.6 and 4.7 means two submissions. And the reviewer checks that the asset actually
works, so make sure the tagged commit is the fixed one.

## 3. Upstream the generator to nightfox.nvim

This is the highest-leverage channel: it makes Godot a first-class Nightfox target so the
`.tet` files regenerate automatically whenever the palettes change, alongside the existing
16 ports.

The PR is small:

1. `lua/nightfox/extra/godot.lua` — the generator (already written).
2. One line in the `extras` table in `misc/extra.lua`:
   ```lua
   godot = { ext = "tet", use_spec_name = true },
   ```
3. Run `nvim --headless --clean -u misc/extra.lua` and commit the generated
   `extra/<variant>/<variant>.tet` files, matching how every other port is committed.

Their CI (`.github/workflows/extra.yml`) regenerates these, so the files stay in sync without
further work. Note this channel ships **only** the syntax themes — the addon stays here,
since it's Godot-specific and outside what nightfox.nvim distributes.

## Versioning

`addons/nightfox/plugin.cfg` carries the version users see in the plugin list. Bump it
together with the git tag and the Asset Library listing — three places, easy to drift.
