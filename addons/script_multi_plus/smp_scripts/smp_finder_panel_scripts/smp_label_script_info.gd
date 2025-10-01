@tool
class_name SMPScriptInfo
extends MarginContainer


@export_enum("CLOSED", "RECENT", "OPENED", "CURRENT") var _info_type: String = "CLOSED"

""" class """
var __c: SMPClassManagers

@onready var _icon_texture_info: TextureRect = %IconTextureInfo
@onready var _label_name_info: Label = %LabelNameInfo


################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item

#endregion
################################################################################
#region set_status

func _set_info_status() -> void:
	_set_icon()
	_set_label_name()
	_set_icon_color()
	var _font_size: int = min(__c._setup_project._get_popup_text_size(), 16)
	_label_name_info.add_theme_font_size_override("font_size", _font_size)

func _set_icon() -> void:
	__c._setup_settings._set_icon_texture(_icon_texture_info)

func _set_label_name() -> void:
	var _text: String
	match _info_type:
		"CLOSED":
			_text = __c._setup_settings._text_dict["closed"]
		"RECENT":
			_text = __c._setup_settings._text_dict["r_info"]
		"OPENED":
			_text = __c._setup_settings._text_dict["o_info"]
		"CURRENT":
			_text = __c._setup_settings._text_dict["curr"]

	_label_name_info.text = _text

#endregion
################################################################################
#region set_color

func _set_icon_color() -> void:
	var _icon_color: Color = __c._setup_settings._color_dict["accent_color"]
	var _text_color: Color = __c._setup_settings._color_dict["txt_color"]
	var _rcolor: Array[Color] = __c._setup_settings._set_blend_inverted_color()
	var _curr_color: Array[Color] = __c._setup_settings._set_blend_inverted_color(0.84)

	match _info_type:
		"CLOSED":
			__c._setup_settings._set_theme_override_font_color(
				_label_name_info, "font_color", _text_color * 1.2
				)
			_icon_texture_info.self_modulate = _text_color * 1.2

		"RECENT":
			__c._setup_settings._set_theme_override_font_color(
				_label_name_info, "font_color", _rcolor[1]
				)
			_icon_texture_info.self_modulate = _rcolor[0]

		"OPENED":
			__c._setup_settings._set_theme_override_font_color(
				_label_name_info, "font_color", _icon_color.lightened(0.4)
				)
			_icon_texture_info.self_modulate = _icon_color * 0.9

		"CURRENT":
			__c._setup_settings._set_theme_override_font_color(
				_label_name_info, "font_color", _curr_color[1]
				)
			_icon_texture_info.self_modulate = _curr_color[0]

#endregion
################################################################################

