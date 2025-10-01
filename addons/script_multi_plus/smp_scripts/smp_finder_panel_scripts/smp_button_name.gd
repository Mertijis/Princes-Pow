@tool
class_name SMPButtonScript
extends MarginContainer


""" class """
var __c: SMPClassManagers
var _find_popup_panel: SMPFindPopupPanel


var _range_jump: int = 3
var _store_name: String
var _store_path: String

var _is_keyboard: bool = false

@onready var _spacer: Control = %Spacer
@onready var _name_button: Button = %NameButton
@onready var _focus_panel: Panel = %FocusPanel


##:: setup
################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item
			elif item is SMPFindPopupPanel:
				_find_popup_panel = item

	_set_ready_signal()
	_set_visible_focus_panel(false)
	__c._setup_settings._set_selected_focus_panel_color(_focus_panel, "panel")
	__c._setup_settings._set_selected_focus_panel_color(_name_button, "focus")

#endregion
################################################################################
#region _signal connect

func _set_ready_signal() -> void:
	__c._setup_signal.connect_button_pressed(_name_button, _on_button_presseed)
	__c._setup_signal.connect_mouse_entered(_name_button, _on_mouse_entered)
	__c._setup_signal.connect_mouse_exited(_name_button, _on_mouse_exited)
	__c._setup_signal.connect_gui_input(_name_button, _on_gui_input)

#endregion
################################################################################
#region _setget_text_size

func _set_name_min_size() -> void:
	var _offset: int = 45
	_name_button.custom_minimum_size.x = _get_text_size().x + _offset

func _get_text_size() -> Vector2:
	var _font: Font = _name_button.get_theme_font("font")
	var _font_size: int = _name_button.get_theme_font_size("font_size")
	var _text: String = _name_button.text
	var _text_size := _font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size)
	if _font_size > 20:
		_name_button.expand_icon = true
	else:
		_name_button.expand_icon = false

	return _text_size

#endregion
################################################################################


##:: status
################################################################################
#region _set_status

func _set_instance_status(_path: String) -> void:
	_set_name_text(_path)
	_set_icon_texture()
	_set_button_font_size()
	_set_name_min_size()
	#print("name_size: ", _name_button.size.y)

func _set_name_text(_path: String) -> void:
	_store_path = _path
	_store_name = _path.get_file()
	_name_button.text = _path.get_file()
	self.name = _path.get_file()

func _set_icon_texture() -> void:
	var _editor_base := EditorInterface.get_base_control()
	var _sc_icon := _editor_base.get_theme_icon("GDScript", "EditorIcons")
	_name_button.icon = _sc_icon

func _set_visible_status(_active: bool) -> void:
	self.set_visible(_active)

func _set_visible_focus_panel(_active: bool) -> void:
	_focus_panel.set_visible(_active)

func _set_button_font_size() -> void:
	var _font_size: int = __c._setup_project._get_popup_text_size()
	__c._setup_settings._set_theme_override_font_size(_name_button, _font_size)

func _set_line_edit_path(_path: String, _type: String) -> void:
	_find_popup_panel._line_edit_path.text = _path.get_base_dir()
	_find_popup_panel._line_edit_path.tooltip_text = _path.get_base_dir()
	match _type:
		"store":
			_find_popup_panel._line_edit_selected._set_line_edit_store_path(_path)
		"hover":
			_find_popup_panel._line_edit_selected._visible_script_status(_path)

func _set_focus_first_container() -> void:
	var _visible_child: Array[SMPButtonScript]
	var _focus_index: int = _name_button.owner.get_index()
	var _sc_container: SMPContainerScript = _find_popup_panel._script_containers[0]
	for child in _sc_container._item_container.get_children():
		if child.is_visible():
			if not _visible_child.has(child):
				_visible_child.push_back(child)
	var _node: SMPButtonScript = _visible_child.get(_focus_index)
	_node._name_button.grab_focus.call_deferred()

func _get_container_num() -> int:
	var _container := self.get_parent().get_parent()
	var _name_int: int = _container.get_index()
	return _name_int

func _get_item_container() -> VBoxContainer:
	var _container := self.get_parent()
	return _container

func _set_group_focus_func() -> void:
	_find_popup_panel._release_visible_focus_panel()
	_find_popup_panel._line_edit_selected._clear_store_path()
	_set_line_edit_path.call_deferred(_store_path, "hover")

func _pressed_key_input() -> void:
	_find_popup_panel._release_focus_temp_container_children()
	_find_popup_panel._release_visible_focus_panel()
	_find_popup_panel._set_is_selected_status(true)
	_set_visible_focus_panel(true)
	_set_line_edit_path(_store_path, "store")
	_find_popup_panel._button_open.grab_focus()

#endregion
################################################################################


##:: signal
################################################################################
#region _signal On_connect

func _on_button_presseed() -> void:
	_find_popup_panel._release_focus_temp_container_children()
	_find_popup_panel._release_visible_focus_panel()
	_find_popup_panel._set_is_selected_status(true)
	_name_button.grab_focus()
	_set_visible_focus_panel(true)
	_set_line_edit_path(_store_path, "store")
	#prints("on_name_button_pressed: ", _name_button.text, _store_path)

func _on_mouse_entered() -> void:
	if not _find_popup_panel._is_selected:
		_set_line_edit_path(_store_path, "hover")

func _on_mouse_exited() -> void:
	if not _find_popup_panel._is_selected:
		_find_popup_panel._line_edit_path.text = ""
		_find_popup_panel._line_edit_selected.text = ""

func _on_gui_input(_event: InputEvent) -> void:
	if _event is InputEventMouseButton:
		if _event.pressed and _event.button_index == MOUSE_BUTTON_RIGHT:
			_find_popup_panel._main_container.gui_input.emit(_event)

	if _event is InputEventKey:
	## key_allow
		if _event.pressed and _event.keycode == KEY_RIGHT:
			var _container_size: int = _find_popup_panel._get_has_container_child()
			var _current_num: int = _get_container_num()
			if _current_num >= _container_size:
				_set_focus_first_container()
				return
			elif _container_size == 0:
				_set_focus_first_container()

		elif _event.pressed and _event.keycode == KEY_BACKSPACE:
			if _name_button.has_focus():
				_find_popup_panel._main_container.gui_input.emit(_event)
				return

		elif not _event.pressed and _event.keycode == KEY_TAB:
			_set_group_focus_func()

		elif _event_key_select_script(_event):
			_set_group_focus_func()

	## grab_focus_jump_previous
		elif _select_key_alt_jump(_event, KEY_H) or \
			_event.pressed and _event.ctrl_pressed and _event.keycode == KEY_UP:
			if _name_button.has_focus():
				var _self_index: int = self.get_index()
				if _self_index < _range_jump:
					_find_popup_panel._selected_sc_item_grab_jump(self, _self_index, _range_jump)
					return
				for i in _range_jump:
					_input_event(KEY_UP)

	## grab_focus_jump_next
		elif _select_key_alt_jump(_event, KEY_N) or \
			_event.pressed and _event.ctrl_pressed and _event.keycode == KEY_DOWN:
			if _name_button.has_focus():
				var _self_index: int = self.get_index()
				var _conta_size: int = self._get_item_container().get_children().size() -1
				var _border: int = _conta_size - _range_jump
				if _self_index > _border:
					_find_popup_panel._selected_sc_item_grab_jump(self, _self_index, _range_jump)
					return
				for i in _range_jump:
					_input_event(KEY_DOWN)

	## key_enter_or_space
		elif not _event.pressed and _event.keycode == KEY_ENTER or \
			not _event.pressed and _event.keycode == KEY_SPACE:
			_pressed_key_input()

		elif _event.pressed and _event.keycode == KEY_F:
			_find_popup_panel._main_container.gui_input.emit(_event)

		elif _select_not_key_alt_pressed(_event, KEY_J, KEY_LEFT):
			if _name_button.has_focus():
				_input_event(KEY_LEFT)
				_is_keyboard = false
				_name_button.accept_event()

		elif _select_not_key_alt_pressed(_event, KEY_L, KEY_RIGHT):
			if _name_button.has_focus():
				_input_event(KEY_RIGHT)
				_is_keyboard = false
				_name_button.accept_event()

		if not _select_key_alt_pressed(_event):
			if not _find_popup_panel._is_selected:
				_set_line_edit_path(_store_path, "hover")
			if not _is_keyboard:
				_input_event_init()
				_is_keyboard = true

#endregion
################################################################################


##:: event_key
################################################################################
#region _event_key_allow

func _event_key_select_script(_event: InputEventKey) -> bool:
	if not _event.pressed and _event.keycode == KEY_UP \
		or not _event.pressed and _event.keycode == KEY_DOWN \
		or not _event.pressed and _event.keycode == KEY_LEFT \
		or not _event.pressed and _event.keycode == KEY_RIGHT:
			return true
	return false

func _select_not_key_alt_pressed( _event: InputEventKey, _key_1: Key, _key_2: Key) -> bool:
	if not _event.pressed and _event.alt_pressed and _event.keycode == _key_1 or \
		not _event.pressed and _event.keycode == _key_2:
		return true
	return false

func _select_key_alt_pressed( _event: InputEventKey) -> bool:
	if _event.pressed and _event.alt_pressed:
		return true
	return false

func _select_key_alt_jump( _event: InputEventKey, _key_1: Key) -> bool:
	if not _event.pressed and _event.alt_pressed and _event.keycode == _key_1:
		return true
	return false

func _input_event(_key: Key) -> void:
	var _new_event := InputEventKey.new()
	_new_event.pressed = true
	_new_event.keycode = _key
	Input.parse_input_event(_new_event)

func _input_event_init() -> void:
	var _new_event := InputEventKey.new()
	_new_event.alt_pressed = false
	Input.parse_input_event(_new_event)

#endregion
################################################################################




