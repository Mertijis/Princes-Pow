@tool
class_name SMPRecentButton
extends MarginContainer

signal selected_item(_id: int)


""" class """
var __c: SMPClassManagers
var _dock_main: ScriptMultiPlusDock
var _store_owner: SMPRecentMenuButton

@export var _store_id: int = 0
var _store_name: String
var _store_path: String
var _store_cont_index: int = -1

var _store_cont_data: Dictionary:
	set(_value):
		_store_cont_data = _value
		_store_path = _store_cont_data["script_path"]
		_store_name = _store_cont_data["script_path"].get_file()
	get:
		return _store_cont_data


var _is_recent_active: bool = false

@onready var _name_button: Button = %NameButton
@onready var _focus_panel: Panel = %FocusPanel


################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item
			elif item is ScriptMultiPlusDock:
				_dock_main = item

	_set_ready_signal()
	_set_visible_focus_panel(false)
	__c._setup_settings._set_selected_focus_panel_color(_focus_panel, "panel")
	__c._setup_settings._set_selected_focus_panel_color(_name_button, "focus")

func _set_store_owner(_owner: SMPRecentMenuButton) -> void:
	_store_owner = _owner

#endregion
################################################################################
#region sig emit

func emit_selected_item(_id: int) -> void:
	selected_item.emit(_id)

#endregion
################################################################################
#region sig connect

func _set_ready_signal() -> void:
	__c._setup_signal.connect_button_pressed(_name_button, _on_button_presseed)
	__c._setup_signal.connect_mouse_entered(_name_button, _on_mouse_entered)
	__c._setup_signal.connect_gui_input(_name_button, _on_gui_input)

#endregion
################################################################################
#region _set_status

func _set_item_checked(_active: bool) -> void:
	_set_icon_texture("chk")
	_set_button_state(_active)

func _set_add_item(_name: String, _id: int, _cont_index: int, _active: bool) -> void:
	if _id > 1:
		if _active:
			_set_icon_texture("chk")
		else:
			_set_icon_texture("uchk")
	else:
		_set_icon_texture("null")

	_name_button.text = _name
	self.name = _name
	_store_id = _id
	_store_cont_index = _cont_index
	_set_button_state(_active)

func _set_icon_texture(_type: String) -> void:
	var _icon: Texture2D = null
	match _type:
		"chk":
			_icon = __c._setup_settings._icon_dict["rad_chk"]
			_set_button_state(true)
		"uchk":
			_icon = __c._setup_settings._icon_dict["rad_uchk"]
			_set_button_state(false)
		"null":
			_icon = null
			_set_button_state(false)
	_name_button.icon = _icon

func _set_button_font_size() -> void:
	var _font_size: int = __c._setup_project._get_popup_text_size()
	__c._setup_settings._set_theme_override_font_size(_name_button, _font_size)

func _get_cont_data_status() -> Dictionary:
	_set_button_state(false)
	return _store_cont_data

## when disabled
func _set_button_focus_bg_alpha(_node: Node, _type: String) -> void:
	__c._setup_settings._set_selected_focus_panel_color(_node, "focus", _type)

#endregion
################################################################################
#region setget

func _set_visible_status(_active: bool) -> void:
	self.set_visible(_active)

func _set_visible_focus_panel(_active: bool) -> void:
	_focus_panel.set_visible(_active)

func _set_button_state(_active: bool) -> void:
	_is_recent_active = _active

func _set_button_disabled_state(_active: bool) -> void:
	_name_button.disabled = _active

func _set_grab_focus_button() -> void:
	_name_button.grab_focus.call_deferred()

func _get_container_num() -> int:
	var _container := self.get_parent().get_parent()
	var _name_int: int = _container.get_index()
	return _name_int

func _get_item_container() -> VBoxContainer:
	var _container := self.get_parent()
	return _container

func _is_loaded_script() -> bool:
	for dict: Dictionary in _dock_main._get_scte_arr():
		var _sc_names: Array = dict.get("sc_name", [])
		if not _sc_names.is_empty():
			if _store_name == _sc_names[1]:
				_store_owner._exist_opened_script_id = _store_id
				return true
	return false

#endregion
################################################################################
#region sig On_connect

func _on_button_presseed() -> void:
	if _name_button.disabled:
		return

	if _is_loaded_script():
		emit_selected_item(_store_owner._store_menu_index)
		return

	if not _is_recent_active:
		_set_icon_texture("chk")

	emit_selected_item(_store_id)
	#prints("on_name_button_pressed: %s" % _store_id)
	#print("on_pressed: ", _store_cont_data)

func _on_mouse_entered() -> void:
	if _name_button.disabled:
		return
	_get_exist_item()


func _on_gui_input(_event: InputEvent) -> void:
	if _event is InputEventKey:
		if not _event.pressed:
			_get_exist_item()

		if _event.pressed:
			var _inputkeys: Dictionary = __c._setup_project._inputkey_dict

			if _event.pressed and _event.is_match(_inputkeys["OpenRecent"]):
				if _name_button.has_focus():
					if _store_owner._recent_popup_panel.visible:
						_store_owner._recent_popup_panel.visible = false

#endregion
################################################################################
#region flash_panel

func _get_exist_item() -> void:
	for dict: Dictionary in _dock_main._get_scte_arr():
		var _name: Array = dict.get("sc_name", [])
		var _ce: CodeEdit = dict.get("code_edit", null)

		if _name.is_empty():
			return
		if _store_name == _name[1]:
			var _ftype: int = __c._setup_project._get_focus_flash_type()
			__c._setup_settings._set_theme_override_panel_focus(_ce, _ftype, "panel")
			return

#endregion
################################################################################
