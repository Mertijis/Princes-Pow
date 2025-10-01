@tool
class_name SMPItemTextSizeButton
extends SMPItemButtonParent

## Not Used

var _button_index: int = 0

var _text_font_size: int = 14

var _close_time: float = 4.6
var _time: float = 0

""" onready """
@onready var _item_open_arrow_button: Button = %ItemOpenArrowButton
@onready var _item_left_button: Button = %ItemLeftButton
@onready var _item_right_button: Button = %ItemRightButton
@onready var _text_size_rich: RichTextLabel = %TextSizeRich


################################################################################
#region signal_ready

func _set_ready_signal() -> void:
	__c._setup_signal.connect_button_pressed(_item_open_arrow_button, _on_button_pressed)
	__c._setup_signal.connect_button_pressed(_item_left_button, _on_left_pressed)
	__c._setup_signal.connect_button_pressed(_item_right_button, _on_right_pressed)

#endregion
################################################################################
#region _notification

func _notification(what: int) -> void:
	if what == NOTIFICATION_INTERNAL_PROCESS:
		_time += get_process_delta_time()
		if _time > _close_time:
			set_process_internal(false)
			_set_status("close")
			_time = 0

#endregion
################################################################################
#region set_ready

func _set_ready_status() -> void:
	_button_index = _get_button_index()
	_set_status("init")

func _get_button_index() -> int:
	var _owner: SMPDockContainer = __c._setup_utility._find_parent_dock_container(self)
	return _owner.container_index

#endregion
################################################################################
#region set_text_box

func _set_status(_set: String) -> void:
	match _set:
		"init":
			_set_tooltips()
			_activity_buttons(true)
			_set_rich_text(_text_font_size)
			_button_index = _get_button_index()
			_set_custom_min_size_x(20)
		"set":
			_activity_buttons(false)
			_set_custom_min_size_x(50)
		"close":
			_activity_buttons(true)
			_set_custom_min_size_x(20)
		_:
			print("Not mach name: ", _set)

func _set_tooltips() -> void:
	var _tooltip_dict := __c._setup_settings._tooltip_dict
	_item_open_arrow_button.tooltip_text = _tooltip_dict["open_arrow"]
	_item_left_button.tooltip_text = _tooltip_dict["left_arrow"]
	_item_right_button.tooltip_text = _tooltip_dict["right_arrow"]

func _activity_buttons(_active: bool) -> void:
	_item_open_arrow_button.set_visible(_active)
	_text_size_rich.set_visible(not _active)
	_item_left_button.set_visible(not _active)
	_item_right_button.set_visible(not _active)

func _set_custom_min_size_x(_size_x: float) -> void:
	self.custom_minimum_size.x = _size_x

#endregion
################################################################################
#region set_rich_label

func _set_rich_text(_text: Variant) -> void:
	if _text is int:
		_text = str(_text)
	var _bbc_text: String = _get_bbc_rich_text(_text)
	_text_size_rich.text = _bbc_text

func _get_bbc_rich_text(_text: String) -> String:
	return "[b]%s[/b]" % _text

#endregion
################################################################################
#region change_font_process

func _set_text_size_handle(_key_int: int = -1, _load_set: int = -1) -> void:
	if _key_int != -1:
		_text_font_size = _load_set

	match _button_index:
		1:
			_dock_main._mcontainer_1._set_font_size(_text_font_size)
		2:
			_dock_main._mcontainer_2._set_font_size(_text_font_size)
		3:
			_dock_main._mcontainer_3._set_font_size(_text_font_size)

#endregion
################################################################################
#region singal On_connect

func _on_button_pressed() -> void:
	_set_status("set")
	set_process_internal(true)

func _on_left_pressed() -> void:
	if _text_font_size > 8:
		_text_font_size -= 1
	else:
		return
	_set_text_size_handle()
	_time = 0

	set_process_internal(true)

func _on_right_pressed() -> void:
	if _text_font_size < 48:
		_text_font_size += 1
	_set_text_size_handle()
	_time = 0

	set_process_internal(true)

#endregion
################################################################################








