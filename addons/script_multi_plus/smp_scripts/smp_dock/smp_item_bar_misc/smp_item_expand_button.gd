@tool
class_name SMPItemExpandButton
extends SMPItemButtonParent


var _button_index: int = 0

var _is_expand_button: bool = false


################################################################################
#region signal_ready

func _set_ready_signal() -> void:
	__c._setup_signal.connect_button_pressed(self, _on_button_pressed)

#endregion
################################################################################
#region set_ready

func _set_ready_status() -> void:
	_button_index = _get_button_index()
	_set_icon_text()
	_set_expand_icon_handle()

func _get_button_index() -> int:
	var _owner: SMPDockContainer = __c._setup_utility._find_parent_dock_container(self)
	return _owner.container_index

#endregion
################################################################################
#region set_status

func _set_icon_tooltip(_type: String) -> void:
	match _type:
		"true":
			var _color: Color = __c._setup_settings._color_dict["accent_color"]
			self.self_modulate = _color
		"false":
			self.self_modulate = Color.WHITE

func _set_icon_text() -> void:
	_set_tooltip_text()
	self.icon = __c._setup_settings._icon_dict["expand"]
	self.text = __c._setup_settings._text_dict["null"]
	__c._setup_settings._set_icon_custom_min_size_x(self, __c._setup_settings._min_size_x["expand"])
	__c._setup_settings._set_icon_alignment(self, "center")

func _set_tooltip_text() -> void:
	var _inputkeys: Dictionary = __c._setup_project._inputkey_dict
	var _ikey:InputEventKey
	var _description: String

	match _button_index:
		1:
			_ikey = _inputkeys.get("Focus_1", null)
		2:
			_ikey = _inputkeys.get("Focus_2", null)
		3:
			_ikey = _inputkeys.get("Focus_3", null)

	if _ikey != null:
		var _key_text: String = _ikey.as_text_keycode()
		_description = __c._setup_settings._tooltip_dict["expand"] % _key_text

	self.tooltip_text = _description

#endregion
################################################################################
#region setget_button_status

func _is_expand_pressed() -> void:
	_is_expand_button = not _is_expand_button

func get_button_state() -> bool:
	return _is_expand_button

func _set_expand_icon_handle() -> void:
	if not _is_expand_button:
		_set_icon_tooltip("false")
	else:
		_set_icon_tooltip("true")

#endregion
################################################################################
#region signal On_connect

func _on_button_pressed() -> void:
	match _button_index:
		1:
			_change_expand_handle([1, 0, 0])
		2:
			_change_expand_handle([0, 1, 0])
		3:
			_change_expand_handle([0, 0, 1])

	_is_expand_pressed()
	_set_expand_handle()
	_set_expand_icon_handle()
	#prints("on_expand_button: ", _button_index, _is_expand_button)

#endregion
################################################################################
#region handle_button

func _set_expand_handle(_key_index: int = -1, _load_set: bool = false) -> void:
	if _key_index != -1:
		_button_index = _key_index
		_is_expand_button = _load_set

	match _button_index:
		1:
			_dock_main._mcontainer_1._set_expand_state(_is_expand_button)
		2:
			_dock_main._mcontainer_2._set_expand_state(_is_expand_button)
		3:
			_dock_main._mcontainer_3._set_expand_state(_is_expand_button)


func _change_expand_handle(_fexp: Array) -> void:
	var _mcont := _dock_main._get_focus_mcontainer(_button_index)
	var _def: Array = [1, 1, 1]
	var _is_D: String = ""

	if _dock_main._is_distract_button:
		_is_D = "D"

	_dock_main._store_focus_index = _button_index

	if not _mcont._get_expand_button_state():
		__c._item_exp_setter._set_focus_expand_selected(_fexp)
		__c._item_exp_setter._change_expand_split_offset("set", _is_D, _fexp)
	else:
		__c._item_exp_setter._set_focus_expand_selected(_def)
		__c._item_exp_setter._change_expand_split_offset("ret", _is_D, _fexp)

	if _mcont._code_edit != null:
		_mcont._code_edit.grab_focus.call_deferred()

#endregion
################################################################################

