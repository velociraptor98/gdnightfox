@tool
extends EditorPlugin

const THEME_DIR := "res://addons/nightfox/themes"

const VARIANTS := {
	"nightfox":  {"light": false, "bg": "#192330", "accent": "#719cd6", "contrast": 0.3,   "saturation": 1.2},
	"duskfox":   {"light": false, "bg": "#232136", "accent": "#c4a7e7", "contrast": 0.3,   "saturation": 1.2},
	"nordfox":   {"light": false, "bg": "#2e3440", "accent": "#81a1c1", "contrast": 0.3,   "saturation": 1.1},
	"terafox":   {"light": false, "bg": "#152528", "accent": "#5a93aa", "contrast": 0.3,   "saturation": 1.2},
	"carbonfox": {"light": false, "bg": "#161616", "accent": "#78a9ff", "contrast": 0.35,  "saturation": 1.2},
	"dayfox":    {"light": true,  "bg": "#f6f2ee", "accent": "#2848a9", "contrast": -0.16, "saturation": 1.0},
	"dawnfox":   {"light": true,  "bg": "#faf4ed", "accent": "#286983", "contrast": -0.16, "saturation": 1.0},
}

const ID_INSTALL := 1000
const ID_UNINSTALL := 1001

var _menu: PopupMenu
var _names: PackedStringArray = []


func _enter_tree() -> void:
	_menu = PopupMenu.new()
	_names = PackedStringArray(VARIANTS.keys())
	for i in _names.size():
		_menu.add_item(_names[i], i)
	_menu.add_separator()
	_menu.add_item("Install theme files for the Color Theme menu", ID_INSTALL)
	_menu.add_item("Remove installed theme files", ID_UNINSTALL)
	_menu.id_pressed.connect(_on_menu_pressed)
	add_tool_submenu_item("Nightfox Theme", _menu)


func _exit_tree() -> void:
	remove_tool_menu_item("Nightfox Theme")
	if is_instance_valid(_menu):
		_menu.queue_free()
	_menu = null


func _on_menu_pressed(id: int) -> void:
	match id:
		ID_INSTALL:
			install_theme_files()
		ID_UNINSTALL:
			remove_theme_files()
		_:
			if id >= 0 and id < _names.size():
				apply(_names[id])


## Absolute path to the editor's text_editor_themes folder, on any platform.
func _themes_dir() -> String:
	return EditorInterface.get_editor_paths().get_config_dir().path_join("text_editor_themes")


## Copies the bundled .tet files into Godot's theme folder so they appear under
## Text Editor > Theme > Color Theme. Only needed to use the themes without this
## plugin -- applying a variant above already sets every color directly.
func install_theme_files() -> int:
	var dest := _themes_dir()
	var err := DirAccess.make_dir_recursive_absolute(dest)
	if err != OK and not DirAccess.dir_exists_absolute(dest):
		push_error("Nightfox: could not create '%s' (error %d)." % [dest, err])
		return 0

	var n := 0
	for variant in VARIANTS:
		var src := "%s/%s.tet" % [THEME_DIR, variant]
		var out := dest.path_join("%s.tet" % variant)
		var copy_err := DirAccess.copy_absolute(ProjectSettings.globalize_path(src), out)
		if copy_err == OK:
			n += 1
		else:
			push_warning("Nightfox: could not copy '%s' (error %d)." % [variant, copy_err])

	print_rich("[color=#719cd6]Nightfox:[/color] installed %d theme file(s) to %s" % [n, dest])
	if n > 0:
		print_rich("[color=#738091]Restart Godot, then pick one under Editor Settings > Text Editor > Theme > Color Theme.[/color]")
	return n


## Removes the .tet files this plugin installed. Leaves other themes alone.
func remove_theme_files() -> int:
	var dir := _themes_dir()
	var n := 0
	for variant in VARIANTS:
		var f := dir.path_join("%s.tet" % variant)
		if FileAccess.file_exists(f) and DirAccess.remove_absolute(f) == OK:
			n += 1
	print_rich("[color=#719cd6]Nightfox:[/color] removed %d theme file(s) from %s" % [n, dir])
	return n


func apply(variant: String) -> bool:
	if not VARIANTS.has(variant):
		push_error("Nightfox: unknown variant '%s'" % variant)
		return false

	var settings := EditorInterface.get_editor_settings()
	var v: Dictionary = VARIANTS[variant]

	settings.set_setting("interface/theme/color_preset", "Custom")
	settings.set_setting("interface/theme/base_color", Color(v["bg"]))
	settings.set_setting("interface/theme/accent_color", Color(v["accent"]))
	settings.set_setting("interface/theme/contrast", v["contrast"])
	settings.set_setting("interface/theme/icon_saturation", v["saturation"])
	settings.set_setting("interface/theme/icon_and_font_color", 1 if v["light"] else 2)
	settings.set_setting("interface/theme/follow_system_theme", false)
	settings.set_setting("interface/theme/use_system_accent_color", false)

	if not _apply_syntax(settings, variant):
		return false

	print_rich("[color=#719cd6]Nightfox:[/color] applied '%s'." % variant)
	return true


func _apply_syntax(settings: EditorSettings, variant: String) -> bool:
	var path := "%s/%s.tet" % [THEME_DIR, variant]
	var cfg := ConfigFile.new()
	var err := cfg.load(path)
	if err != OK:
		push_error("Nightfox: could not read '%s' (error %d)." % [path, err])
		return false
	if not cfg.has_section("color_theme"):
		push_error("Nightfox: '%s' has no [color_theme] section." % path)
		return false

	for key in cfg.get_section_keys("color_theme"):
		var raw := str(cfg.get_value("color_theme", key))
		var color := _parse_rgba(raw)
		if color == null:
			push_warning("Nightfox: skipping malformed color '%s' for key '%s'." % [raw, key])
			continue
		settings.set_setting("text_editor/theme/highlighting/%s" % key, color)

	settings.set_setting("text_editor/theme/color_theme", "Custom")
	return true


## Parses an `rrggbbaa` string (Godot's .tet format) into a Color.
## Returns null if the value is not 8 hex digits.
func _parse_rgba(value: String) -> Variant:
	var hex := value.strip_edges().trim_prefix("#")
	if hex.length() != 8 or not hex.is_valid_hex_number():
		return null
	return Color.from_string("#" + hex, Color.BLACK)
