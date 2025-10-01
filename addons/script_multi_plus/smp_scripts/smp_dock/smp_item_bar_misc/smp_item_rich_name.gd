@tool
class_name SMPItemRichName
extends SMPItemButtonParent


var _button_index: int = 0
var _store_script_names: Array[String]

var _time: float = 0

@onready var _rich_name: RichTextLabel = %RichName


################################################################################
#region _set_ready

func _set_ready_status() -> void:
	_rich_name.text = __c._setup_settings._text_dict["init"]
	__c._setup_settings._set_rich_label_font_size(_rich_name)
	_button_index = _get_button_index()
	_set_font_color()

func _get_button_index() -> int:
	var _owner: SMPDockContainer = __c._setup_utility._find_parent_dock_container(self)
	return _owner.container_index

#endregion
################################################################################
#region handle_rich_label

func _set_rich_label_handle(_tindex: int, _load_value: Array[String] = []) -> void:
	match _button_index:
		1:
			_dock_main._mcontainer_1._set_title_name(_tindex, _load_value)
		2:
			_dock_main._mcontainer_2._set_title_name(_tindex, _load_value)
		3:
			_dock_main._mcontainer_3._set_title_name(_tindex, _load_value)

#endregion
################################################################################
#region set_label_name

func _set_rich_label_name(_text: Array[String]) -> void:
	if _text.is_empty():
		return
	_store_script_names = _text
	_rich_name.text = "%s / %s" % [
		_get_bbcode_text(_text[0], "bold"), _get_bbcode_text(_text[1], "normal")
		]
	_rich_name.tooltip_text = "%s / %s" %[_text[0], _text[1]]
	_set_font_color()

func _set_font_color() -> void:
	var _color: Color = __c._setup_settings._color_dict["class_color"]
	__c._setup_settings._set_rich_label_default_color(_rich_name, _color * 1.05)

func _get_bbcode_text(_text: String, _type: String) -> String:
	match _type:
		"normal":
			return "%s" % _text
		"bold":
			return "[b]%s[/b]" % _text
	return _text

func _set_init_rich_name() -> void:
	_rich_name.text =__c. _setup_settings._text_dict["init"]
	_rich_name.tooltip_text = ""
	_set_font_color()

#endregion
################################################################################






