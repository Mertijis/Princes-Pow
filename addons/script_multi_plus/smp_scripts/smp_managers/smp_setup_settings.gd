@tool
class_name ScriptMultiPlusSettings
extends Resource


""" config_file """
var _section: String:
	set(_value):
		_section = _value
	get:
		return _section

var _conf_path: String:
	set(_value):
		_conf_path = _value
	get:
		return _conf_path

var _editor_settings := EditorInterface.get_editor_settings()

var _grab_thick_size: int = 14

var _finder_script_row_min_size: int = 20:
	set(_value):
		_finder_script_row_min_size = _value
	get:
		return _finder_script_row_min_size


##:: status
################################################################################
#region _sett_scene_resource

var _scene_popup_res: Dictionary = {
	"button_folder": load("uid://27j7kv0hee03"),
	"button_script": load("uid://c1pit1mahbyj4"),
	"recent_button": load("uid://bpkf8jbsgcia4"),
	"recent_line"  : load("uid://bfhy0s8po6ofp"),
}

#endregion
################################################################################
#region _sett_color

func _set_color_value(_color_path: String) -> Color:
	var _color: Color = _editor_settings.get_setting(_color_path)
	return _color

var _color_dict: Dictionary = {
	"accent_color": _set_color_value("interface/theme/accent_color"),
	"bg_color"    : _set_color_value("text_editor/theme/highlighting/background_color"),
	"base_color"  : _set_color_value("text_editor/theme/highlighting/base_type_color"),
	"txt_color"   : _set_color_value("text_editor/theme/highlighting/text_color"),
	"class_color" : _set_color_value("text_editor/theme/highlighting/user_type_color"),
	"symbol_color": _set_color_value("text_editor/theme/highlighting/symbol_color"),
	"mark_color"  : _set_color_value("text_editor/theme/highlighting/mark_color"),
	"numb_color"  : _set_color_value("text_editor/theme/highlighting/number_color"),
	"func_color"  : _set_color_value("text_editor/theme/highlighting/function_color"),
	"find_color"  : _set_color_value("text_editor/theme/highlighting/search_result_border_color"),
	"reig_color"  : _set_color_value("text_editor/theme/highlighting/folded_code_region_color"),
	"key_color"   : _set_color_value("text_editor/theme/highlighting/keyword_color"),
	"transparent" : Color(0,0,0,0),

	#"globf_color" : _set_color_value("text_editor/theme/highlighting/gdscript/global_function_color"),
	#"fkey_color"  : _set_color_value("text_editor/theme/highlighting/control_flow_keyword_color"),
}

#endregion
################################################################################
#region _sett_save_key

var _save_key_name: Dictionary = {
	"dock_1H"  	: "dock_split_1H",
	"dock_1V"  	: "dock_split_1V",
	"dock_2H"  	: "dock_split_2H",
	"dock_2V"  	: "dock_split_2V",

	"dock_1HD"  : "dock_split_1HD",
	"dock_1VD"  : "dock_split_1VD",
	"dock_2HD"  : "dock_split_2HD",
	"dock_2VD"  : "dock_split_2VD",

	"expand"   : "exp_button",
	"vert"     : "vert_button",
	"boundary" : "wrap_mode",
	"m_map"    : "minimap",
	"add"      : "add_button",

	"s_name"   : "sc_name",
	"sc_path"  : "script_path",
	"suid_path": "uid_path",
	"f_index"  : "focus_index",
	"t_index"  : "tab_index",

	"f_size"   : "font_size", ## not used
}

#endregion
################################################################################


##:: custom_min_size
################################################################################
#region _sett_custom_min_size_x

func _set_icon_custom_min_size_x(_node: Node, _size_x: float) -> void:
	_node.custom_minimum_size.x = _size_x

#endregion
################################################################################
#region _sett_custom_min_x

var _min_size_x: Dictionary = {
	"expand"   : 32,
	"recent"   : 28,
	"diraccess": 32,
	"vert"     : 30,
	"attach"   : 30,
	"edit"     : 30,
	"remove"   : 30,
	"boundary" : 30,
	"minimap"  : 30,
	"add"      : 30,
	"btn_bot"  : 200,
}

#endregion
################################################################################


##:: icon
################################################################################
#region _sett_icon

var _icon_dict: Dictionary = {
	"expand"   : load("res://addons/script_multi_plus/sme_images/godot_Stretch.svg"),
	"recent"   : load("res://addons/script_multi_plus/sme_images/godot_AnimationTrackList.svg"),
	"diraccess": load("res://addons/script_multi_plus/sme_images/godot_Save.svg"),
	"vert"     : load("res://addons/script_multi_plus/sme_images/godot_Panels2.svg"),
	"hori"     : load("res://addons/script_multi_plus/sme_images/godot_Panels2Alt.svg"),
	"attach"   : load("res://addons/script_multi_plus/sme_images/godot_Script.svg"),
	"edit"     : load("res://addons/script_multi_plus/sme_images/godot_Edit.svg"),
	"remove"   : load("res://addons/script_multi_plus/sme_images/godot_Remove.svg"),
	"boundary" : load("res://addons/script_multi_plus/sme_images/godot_MirrorX.svg"),
	"minimap"  : load("res://addons/script_multi_plus/sme_images/godot_CodeHighlighter.svg"),
	"add"      : load("res://addons/script_multi_plus/sme_images/godot_Add.svg"),
	"minus"    : load("res://addons/script_multi_plus/sme_images/godot_CurveConstant.svg"),
	"rad_chk"  : load("res://addons/script_multi_plus/sme_images/godot_GuiRadioChecked.svg"),
	"rad_uchk" : load("res://addons/script_multi_plus/sme_images/godot_GuiRadioUnchecked.svg"),
}

func _set_icon_texture(_node: Node, _select: String = "tex", _type: String = "norm") -> void:
	var _icon_type: String

	match _type:
		"norm":
			_icon_type = "GDScript"
		"int":
			_icon_type = "GDScriptInternal"

	var _editor_base := EditorInterface.get_base_control()
	var _sc_icon: Texture2D = _editor_base.get_theme_icon(_icon_type, "EditorIcons")

	if _select == "tex":
		_node.texture = _sc_icon
	else:
		_node.icon = _sc_icon

#endregion
################################################################################
#region _sett_icon_color

func _set_icon_loaded_color(_child: SMPButtonScript, i_color: Color, n_color: Color) -> void:
	_set_theme_override_font_color(_child._name_button, "font_color", n_color.lightened(0.4))
	_set_theme_override_font_color(_child._name_button, "font_hover_color", n_color * 1.2)
	_set_theme_override_font_color(_child._name_button, "font_focus_color", n_color * 1.3)
	_set_theme_override_icon_color(_child._name_button, "icon_normal_color", i_color * 0.9)
	_set_theme_override_icon_color(_child._name_button, "icon_hover_color", i_color * 1.08)
	_set_theme_override_icon_color(_child._name_button, "icon_focus_color", i_color * 1.25)

func _set_icon_closed_color(_child: SMPButtonScript, t_color: Color) -> void:
	_set_theme_override_font_color(_child._name_button, "font_color", t_color * 1.0)
	_set_theme_override_font_color(_child._name_button, "font_hover_color", t_color * 1.2)
	_set_theme_override_font_color(_child._name_button, "font_focus_color", t_color * 1.1)

#endregion
################################################################################


##:: text
################################################################################
#region _sett_text

var _text_dict: Dictionary = {
	"null"  : "",
	"init"  : "[b]none...[/b]",
	"attach_1": "Attach_1",
	"attach_2": "Attach_2",
	"attach_3": "Attach_3",
	"c_info"  : "class_name",
	"e_info"  : "extends",
	"o_info"  : "Opened",
	"r_info"  : "Recent",
	"closed"  : "Closed",
	"curr"    : "Current",

	#"vert"  : "Vert",
	#"hori"  : "Hori",
	#"attach": "Attach",
	#"edit"  : "Edit",
	#"add"   : "Add",
}

#endregion
################################################################################
#region _sett_tooltip

var _tooltip_dict: Dictionary = {
	"expand"     : " Focus*   :  Focus script window. \n\
					Focused* : Expand the focus script window. \n\
					*( %s )",

	"recent"     : " Open recent file gd. \n\
					( %s ) ",

	"diraccess"  : " #1 Hold left click :  delete Containers save data. \n\
					#2 Hold right click :  delete All save data. ",

	"vert"       : " Toggles between horizontal and vertical layout. ",

	"boundary"   : " Enables line wrapping. ",
	"minimap"    : " Minimap: show / hide ",
	"add"        : " Add a script window. ",
	"minus"      : " Hide a script window. ",

	#"open_arrow" : " open / text size ",
	#"left_arrow" : " - size ",
	#"right_arrow": " + size ",
	#"sel_folder" : " Right-click or Backspace to deselect the folder.",
}

#endregion
################################################################################
#region _sett_error_logger_resource

var _err_text: Dictionary = {
	"cl_name": "ScriptMultiPlusFileSystem",

	"log_suc": "Save successfully",
	"log_sfa": "Save failed, path does not exist.",
	"log_com": "Completed: temp file remove:: %s, %s",

	"log_sav": "Failed save data. Error writing file: %s, ",
	"log_err": "Failed saving. Error temp file: %s, %s",
	"log_exs": "Not exists data to load.",

	"load_fa": "Failed loading data.",
	"load_bo": "Loaded data",
}

#endregion
################################################################################


##:: override
################################################################################
#region _sett_override

func _set_theme_override_header_panel(_node: Node) -> void:
	var _stylebox := StyleBoxFlat.new()
	_stylebox.border_color = _color_dict["accent_color"]
	_stylebox.bg_color = _color_dict["bg_color"].lightened(0.01)
	#_stylebox.border_width_top = 1
	#_stylebox.border_width_left = 1
	#_stylebox.border_width_right = 1
	_stylebox.border_width_bottom = 1
	_stylebox.border_color.a = 0.15
	_node.add_theme_stylebox_override("panel", _stylebox)

""" color """
func _set_theme_override_font_color(_node: Node, _type: String, _color: Color) -> void:
	_node.add_theme_color_override(_type, _color)

func _set_theme_override_icon_color(_node: Node, _theme: String, _color: Color) -> void:
	_node.add_theme_color_override(_theme, _color)

func _set_rich_label_default_color(_node: RichTextLabel, _color: Color) -> void:
	_node.add_theme_color_override("default_color", _color)

""" font_size """
func _set_theme_override_font_size(_node: Node, _font_size: int) -> void:
	_node.add_theme_font_size_override("font_size", _font_size)

func _set_rich_label_font_size(_node: RichTextLabel) -> void:
	var _font_size: int = _editor_settings.get_setting("interface/editor/main_font_size")
	_node.add_theme_font_size_override("bold_font_size", _font_size)

#endregion
################################################################################
#region sett_override_grab_thickness

""" grab_thickness """
func _set_theme_override_min_grab_thick(
	_node: SplitContainer, _size: int, _state: bool
	) -> void:

	_node.add_theme_constant_override("minimum_grab_thickness", _size)
	_node.drag_area_margin_begin = 24
	_node.drag_area_margin_end = 42
	match _state:
		false:
			_node.drag_area_offset = 6
		true:
			_node.drag_area_offset = -4
			_node.drag_area_margin_begin = 30

#endregion
################################################################################
#region sett_override_code_edit_panel

""" code_edit """
func _set_theme_override_panel_focus(_node: Node, _ftype: int, _type: String = "focus") -> void:
	if _ftype == 0:
		return

	var _stylebox := StyleBoxFlat.new()
	var _panel: Panel
	var _bg_alpha: float = 0.0
	var _duration: float = 0.75
	var _border_width: int = 24
	var _offset_plus: int = 0

	match _type:
		"panel":
			_panel = Panel.new()
			_bg_alpha = 0.0
			_duration = 0.5
			_border_width = 16
			_offset_plus = 2

	match _ftype:
		1: ## normal
			_stylebox.border_blend = false
			_stylebox.set_border_width_all(1 + _offset_plus)
		2: ## flash
			_stylebox.border_blend = true

	_stylebox.border_color = _color_dict["accent_color"].darkened(0.35)
	_stylebox.bg_color = _color_dict["accent_color"].darkened(0.6) * 0.35
	_stylebox.anti_aliasing = false
	_stylebox.bg_color.a = _bg_alpha
	_stylebox.set_corner_radius_all(1)
	_node.add_theme_stylebox_override("focus", _stylebox)

	match _type:
		"panel":
			_stylebox.border_color = _set_blend_inverted_color()[0]
			_stylebox.border_color.a = 0.6
			_panel.add_theme_stylebox_override("panel", _stylebox)
			_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
			_node.add_child(_panel)

	var _t: Tween = _node.get_tree().create_tween()
	match _ftype:
		1:
			_t.tween_method(
				_panel_tween_alpha.bind(_stylebox), _bg_alpha, 0.02, _duration
				)
		2:
			_t.set_parallel(true)

			_t.tween_method(
				_panel_tween_alpha.bind(_stylebox), _bg_alpha, 0.01, _duration
				)
			_t.tween_method(
				func(_alpha: float) -> void:
					_stylebox.border_width_left = _alpha
					_stylebox.border_width_right = _alpha
					_stylebox.border_width_top = _alpha
					_stylebox.border_width_bottom = _alpha
			, _border_width, 4, _duration)

	match _type:
		"panel":
			await _t.finished
			_stylebox.border_color = _color_dict["accent_color"].darkened(0.35)
			_stylebox.set_border_width_all(1)
			_panel.queue_free()

func _set_theme_override_panel_focus_misc(_node: Node) -> void:
	var _stylebox := StyleBoxFlat.new()
	var _bg_alpha: float = 0.2
	var _border_width: int = 24

	_stylebox.anti_aliasing = false
	_stylebox.border_blend = true
	_stylebox.border_color = _color_dict["accent_color"].darkened(0.45)
	_stylebox.bg_color = _color_dict["accent_color"].darkened(0.8) * 0.35
	_stylebox.bg_color.a = _bg_alpha
	_stylebox.set_border_width_all(8)
	_stylebox.set_corner_radius_all(1)
	_node.add_theme_stylebox_override("focus", _stylebox)

func _set_theme_override_panel_normal_misc(_node: Node) -> void:
	var _stylebox := StyleBoxFlat.new()
	var _margins: int = 24
	_stylebox.anti_aliasing = false
	_stylebox.corner_detail = 3
	_stylebox.bg_color = _color_dict["bg_color"]
	_stylebox.border_color = _color_dict["bg_color"]
	_stylebox.content_margin_left = _margins
	_stylebox.content_margin_right = _margins
	_stylebox.content_margin_top = 4
	_stylebox.content_margin_bottom = 4
	_stylebox.set_corner_radius_all(2)
	_node.add_theme_stylebox_override("normal", _stylebox)

func _panel_tween_alpha(_alpha: float, _stylebox: StyleBoxFlat) -> void:
	_stylebox.bg_color.a = _alpha

func _remove_theme_override_panel_focus(_node: Node) -> void:
	_node.remove_theme_stylebox_override("focus")

#endregion
################################################################################
#region sett_override_popup_panel_color

func _set_theme_override_popup_panel(_node: Node) -> void:
	var _stylebox := StyleBoxFlat.new()
	_stylebox.border_color = _color_dict["accent_color"] * 0.75
	_stylebox.bg_color = _color_dict["bg_color"].lightened(0.02)
	_stylebox.border_width_top = 20
	_stylebox.border_width_left = 1
	_stylebox.border_width_right = 1
	_stylebox.border_width_bottom = 1
	_stylebox.corner_radius_bottom_left = 2
	_stylebox.corner_radius_bottom_right = 2
	_node.add_theme_stylebox_override("panel", _stylebox)

func _set_theme_override_code_number_panel(_node: Node) -> void:
	var _stylebox := StyleBoxFlat.new()
	_stylebox.border_color = _color_dict["accent_color"].darkened(0.4)
	_stylebox.bg_color = _color_dict["accent_color"].darkened(0.5)
	_stylebox.set_border_width_all(1)
	_stylebox.set_corner_radius_all(1)
	_node.add_theme_stylebox_override("normal", _stylebox)

func _set_selected_focus_panel_color(_node: Node, _style: String, _type: String = "nom") -> void:
	var _stylebox := StyleBoxFlat.new()
	_stylebox.border_color = Color(0.8, 0.8, 0.8, 0.2)
	_stylebox.bg_color = _color_dict["accent_color"].lightened(0.2)
	_stylebox.bg_color *= 0.4

	match _type:
		"nom":
			_stylebox.bg_color.a = 0.7
		"dis":
			_stylebox.bg_color.a = 0.0

	_stylebox.expand_margin_left = 8
	_stylebox.expand_margin_right = 6
	_stylebox.set_border_width_all(1)
	_node.add_theme_stylebox_override(_style, _stylebox)

func _set_blend_inverted_color(_shift: float = 0.1) -> Array[Color]:
	var _icon_color: Color = _color_dict["accent_color"]
	var _blend_icon := _icon_color.inverted()
	var _shift_h: float = _shift

	var _h := wrapf(_blend_icon.h + _shift_h, 0, 1.0)
	var _s := wrapf(_blend_icon.s * 1.1, 0, 1.0)
	var _v := wrapf(_blend_icon.v * 0.9, 0, 1.0)
	var _shift_color := Color.from_hsv(_h, _s, _v)
	_shift_color.a = 1.0

	return [_shift_color.lightened(0.1), _shift_color.lightened(0.2)]

#endregion
################################################################################


##:: other
################################################################################
#region _sett_node_status

func _set_icon_alignment(_node: Node, _align: String) -> void:
	match _align:
		"left":
			_node.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		"center":
			_node.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		"right":
			_node.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func _set_container_flag(_node: Node, _type: String) -> void:
	match _type:
		"exp":
			_node.size_flags_vertical = Control.SIZE_EXPAND_FILL
		"fill":
			_node.size_flags_vertical = Control.SIZE_FILL

func _set_mouse_filter(_control: Control, _type: String) -> void:
	match _type:
		"stop":
			_control.mouse_filter = Control.MOUSE_FILTER_STOP
		"pass":
			_control.mouse_filter = Control.MOUSE_FILTER_PASS
		"ignore":
			_control.mouse_filter = Control.MOUSE_FILTER_PASS

#endregion
################################################################################

