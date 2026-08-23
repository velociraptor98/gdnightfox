local template = require("nightfox.util.template")

local M = {}

---@param color string css hex color
---@param alpha string|nil two digit hex alpha, defaults to "ff"
---@return string
local function conv(color, alpha)
	return color:gsub("^#", "") .. (alpha or "ff")
end

function M.generate(spec, _)
	local p = spec.palette
	local s = spec.syntax

	local colors = {
		meta = p.meta,

		-- Editor chrome
		bg = conv(spec.bg1),
		bg_alt = conv(spec.bg0),
		bg_popup = conv(spec.sel0),
		guideline = conv(spec.bg3),
		fg = conv(spec.fg1),
		fg_dim = conv(spec.fg2),
		line_nr = conv(spec.fg3),
		caret = conv(spec.fg0),
		caret_bg = conv(spec.bg0),
		selection = conv(spec.sel1),
		highlight = conv(spec.sel0),
		current_line = conv(spec.fg1, "0d"),
		folded = conv(p.magenta.base, "33"),

		-- Syntax
		comment = conv(s.comment),
		doc_comment = conv(s.comment),
		keyword = conv(s.keyword),
		conditional = conv(s.conditional),
		operator = conv(s.operator),
		type = conv(s.type),
		builtin_type = conv(s.builtin1),
		user_type = conv(s.builtin2),
		string = conv(s.string),
		string_alt = conv(s.regex),
		number = conv(s.number),
		func = conv(s.func),
		builtin_func = conv(s.builtin0),
		field = conv(s.field),
		preproc = conv(s.preproc),
		node_path = conv(p.green.base),
		node_ref = conv(p.green.bright),

		-- Diagnostics
		error = conv(spec.diag.error),
		error_mark = conv(spec.diag.error, "38"),
		warn = conv(spec.diag.warn),
		warn_mark = conv(spec.diag.warn, "26"),
		info = conv(spec.diag.info),
		ok = conv(spec.diag.ok),
		exec_line = conv(p.yellow.bright),
		bookmark = conv(p.blue.base),
	}

	local content = [[
; Nightfox theme for the Godot script editor
; name: ${meta.name}
; upstream: ${meta.url}
;
; Install: copy this file into Godot's `text_editor_themes` folder, then pick it
; under Editor > Editor Settings > Text Editor > Theme > Color Theme.
;   Linux:   ~/.config/godot/text_editor_themes
;   macOS:   ~/Library/Application Support/Godot/text_editor_themes
;   Windows: %APPDATA%\Godot\text_editor_themes

[color_theme]

background_color="${bg}"
text_color="${fg}"
line_number_color="${line_nr}"
safe_line_number_color="${ok}"
caret_color="${caret}"
caret_background_color="${caret_bg}"
current_line_color="${current_line}"
line_length_guideline_color="${guideline}"
word_highlighted_color="${highlight}"
selection_color="${selection}"
text_selected_color="00000000"
code_folding_color="${line_nr}"
folded_code_region_color="${folded}"
search_result_color="${highlight}"
search_result_border_color="${selection}"

completion_background_color="${bg_alt}"
completion_selected_color="${highlight}"
completion_existing_color="${selection}"
completion_scroll_color="${line_nr}"
completion_scroll_hovered_color="${fg_dim}"
completion_font_color="${fg_dim}"

symbol_color="${operator}"
keyword_color="${keyword}"
control_flow_keyword_color="${conditional}"
base_type_color="${type}"
engine_type_color="${builtin_type}"
user_type_color="${user_type}"
comment_color="${comment}"
doc_comment_color="${doc_comment}"
string_color="${string}"
string_placeholder_color="${string_alt}"
number_color="${number}"
function_color="${func}"
member_variable_color="${field}"

brace_mismatch_color="${error}"
mark_color="${error_mark}"
warning_color="${warn_mark}"
bookmark_color="${bookmark}"
breakpoint_color="${error}"
executing_line_color="${exec_line}"

gdscript/function_definition_color="${func}"
gdscript/global_function_color="${builtin_func}"
gdscript/node_path_color="${node_path}"
gdscript/node_reference_color="${node_ref}"
gdscript/annotation_color="${preproc}"
gdscript/string_name_color="${string_alt}"

comment_markers/critical_color="${error}"
comment_markers/warning_color="${warn}"
comment_markers/notice_color="${info}"
]]

	return template.parse_template_str(content, colors)
end

return M
