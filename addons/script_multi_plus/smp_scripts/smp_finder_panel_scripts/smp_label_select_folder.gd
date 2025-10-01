@tool
class_name SMPSelectFolder
extends MarginContainer


""" class """
var __c: SMPClassManagers


@onready var _icon_texture_folder: TextureRect = %IconTextureFolder
@onready var _label_select_folder: Label = %LabelSelectFolder


################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item

	_set_label_name("ALL")
	_set_font_size()

#endregion
################################################################################
#region _set_ready

func _set_init_label() -> void:
	_set_label_name("ALL")
	_set_icon_color(Color.WHITE * 0.95)

func _set_data_labels(_select: SMPButtonFolder) -> void:
	_set_label_name(_select._store_name)
	_set_icon_color(_select._store_color)
	_set_font_size()

func _set_label_name(_text: String) -> void:
	_label_select_folder.text = _text
	_label_select_folder.tooltip_text = _text

func _set_icon_color(_color: Color) -> void:
	_icon_texture_folder.self_modulate = _color

func _set_font_size() -> void:
	var _font_size: int = _get_font_size_limit()
	_label_select_folder.add_theme_font_size_override("font_size", _font_size)

func _get_font_size_limit() -> int:
	var _font_size: int = __c._setup_project._get_popup_text_size()
	if _font_size <= 16:
		_font_size = 12
	elif _font_size <= 18:
		_font_size = 14
	elif _font_size <= 26:
		_font_size = 16
	else:
		_font_size = 22
	return _font_size

#endregion
################################################################################


