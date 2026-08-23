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

var _menu: PopupMenu
var _names: PackedStringArray = []


func _enter_tree() -> void:
	_menu = PopupMenu.new()
	_names = PackedStringArray(VARIANTS.keys())
	for i in _names.size():
		_menu.add_item(_names[i], i)
	_menu.id_pressed.connect(_on_variant_selected)
	add_tool_submenu_item("Nightfox Theme", _menu)


func _exit_tree() -> void:
	remove_tool_menu_item("Nightfox Theme")
	if is_instance_valid(_menu):
		_menu.queue_free()
	_menu = null


func _on_variant_selected(id: int) -> void:
	if id < 0 or id >= _names.size():
		return
	apply(_names[id])


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
