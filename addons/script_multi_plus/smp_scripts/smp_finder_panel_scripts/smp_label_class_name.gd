@tool
class_name SMPLabelClassName
extends HBoxContainer


""" class """
var __c: SMPClassManagers

@onready var _label_class_name: Label = %LabelClassName
@onready var _rich_text_class_name: RichTextLabel = %RichTextClassName
@onready var _mcontainer: MarginContainer = %MContainer


################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item

	_set_label_name()
	_set_rich_label_name()

#endregion
################################################################################
#region _set_ready

func _set_label_name() -> void:
	var _font_size: int = _get_font_size_limit()
	var _color: Color = __c._setup_settings._color_dict["key_color"]
	_label_class_name.text = __c._setup_settings._text_dict["c_info"]
	_label_class_name.add_theme_font_size_override("font_size", _font_size)
	__c._setup_settings._set_theme_override_font_color(_label_class_name, "font_color", _color)

func _set_rich_label_name() -> void:
	var _font_size: int = min(__c._setup_project._get_popup_text_size(), 24)
	_rich_text_class_name.text = __c._setup_settings._text_dict["init"]
	_rich_text_class_name.add_theme_font_size_override("bold_font_size", _font_size)
	_set_font_color()

func _get_font_size_limit() -> int:
	var _font_size: int = __c._setup_project._get_popup_text_size()
	if _font_size <= 16:
		_font_size = 12
		_mcontainer.add_theme_constant_override("margin_top", 6)
	elif _font_size <= 18:
		_font_size = 14
		_mcontainer.add_theme_constant_override("margin_top", 4)
	elif _font_size <= 26:
		_font_size = 16
		_mcontainer.add_theme_constant_override("margin_top", 2)
	else:
		_font_size = 18
		_mcontainer.add_theme_constant_override("margin_top", 0)
	return _font_size

#endregion
################################################################################
#region set_label_name

func _set_rich_text_insert(_text: String) -> void:
	if _text == "":
		_rich_text_class_name.text = ""
		return
	_rich_text_class_name.text = "%s" % _get_bbcode_text(_text, "bold")
	_set_font_color()

func _set_font_color() -> void:
	var _color: Color = __c._setup_settings._color_dict["class_color"]
	__c._setup_settings._set_rich_label_default_color(_rich_text_class_name, _color * 1.05)

func _get_bbcode_text(_text: String, _type: String) -> String:
	match _type:
		"normal":
			return "%s" % _text
		"bold":
			return "[b]%s[/b]" % _text
	return _text

func _set_init_rich_name() -> void:
	_rich_text_class_name.text = __c._setup_settings._text_dict["init"]
	_rich_text_class_name.tooltip_text = ""
	_set_font_color()

#endregion
################################################################################

