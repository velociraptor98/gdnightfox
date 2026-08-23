#!/usr/bin/env sh
# Installs the Nightfox .tet syntax themes into Godot's editor theme folder.
#
# This is the "syntax colors only" route — it needs no plugin and no project.
# Godot's editor settings are global, so this applies to every project you open.
#
# Usage: ./install.sh [--uninstall]

set -eu

SRC="$(cd "$(dirname "$0")" && pwd)/addons/nightfox/themes"

case "$(uname -s)" in
  Darwin) DEST="$HOME/Library/Application Support/Godot/text_editor_themes" ;;
  Linux)  DEST="${XDG_CONFIG_HOME:-$HOME/.config}/godot/text_editor_themes" ;;
  MINGW*|MSYS*|CYGWIN*) DEST="${APPDATA:-$HOME/AppData/Roaming}/Godot/text_editor_themes" ;;
  *) echo "Unsupported OS: $(uname -s)" >&2
     echo "Copy $SRC/*.tet into Godot's text_editor_themes folder manually." >&2
     exit 1 ;;
esac

if [ ! -d "$SRC" ]; then
  echo "error: theme source not found at $SRC" >&2
  exit 1
fi

if [ "${1:-}" = "--uninstall" ]; then
  n=0
  for f in "$SRC"/*.tet; do
    name="$(basename "$f")"
    if [ -f "$DEST/$name" ]; then rm -f "$DEST/$name"; n=$((n + 1)); fi
  done
  echo "Removed $n theme(s) from $DEST"
  exit 0
fi

mkdir -p "$DEST"
n=0
for f in "$SRC"/*.tet; do
  cp "$f" "$DEST/"
  n=$((n + 1))
done

echo "Installed $n Nightfox theme(s) to:"
echo "  $DEST"
echo
echo "Restart Godot if it is open, then pick one under:"
echo "  Editor > Editor Settings > Text Editor > Theme > Color Theme"
