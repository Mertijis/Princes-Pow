@tool
class_name SMPButtonFolder
extends MarginContainer


""" class """
var __c: SMPClassManagers
var _find_popup_panel: SMPFindPopupPanel

var _range_jump: int = 4
var _button_index_folder: int = 0
var _store_name: String
var _store_parent: String
var _store_color: Color

var _folder_container: SMPContainerFolder

@onready var _spacer: Control = %Spacer
@onready var _folder_button: Button = %FolderButton
@onready var _focus_panel: Panel = %FocusPanel


##:: setup
################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item
			elif item is SMPContainerFolder:
				_folder_container = item
			elif item is SMPFindPopupPanel:
				_find_popup_panel = item

	_set_ready_signal()
	_set_visible_focus_panel(false)
	__c._setup_settings._set_selected_focus_panel_color(_focus_panel, "panel")
	__c._setup_settings._set_selected_focus_panel_color(_folder_button, "focus")

#endregion
################################################################################
#region _set_signal

func _set_ready_signal() -> void:
	__c._setup_signal.connect_gui_input(_folder_button, _on_gui_input)
	__c._setup_signal.connect_button_pressed(_folder_button, _on_button_presseed)

#endregion
################################################################################


##:: status
################################################################################
#region _set_status

func _set_instance_status(
	_name: String, _path: String, _color: Color, _left_space: int, _index: int
	) -> void:
	_set_name_text(_name)
	_set_store_parent(_path)
	_set_icon_color(_color)
	_set_space_left_size(_left_space)
	_set_button_font_size()
	_button_index_folder = _index
	#_set_name_min_size()

func _set_name_text(_name: String) -> void:
	_folder_button.text = _name
	_store_name = _name

func _set_store_parent(_path: String) -> void:
	_store_parent = _path

func _set_space_left_size(_size: int = 0) -> void:
	if _size <= 0:
		_spacer.visible = false
	_spacer.custom_minimum_size.x = _size

func _set_visible_focus_panel(_active: bool) -> void:
	_focus_panel.set_visible(_active)

func _set_icon_color(_color: Color) -> void:
	_folder_button.add_theme_color_override("icon_normal_color", _color * 0.87)
	_folder_button.add_theme_color_override("icon_hover_color", _color * 1.1)
	_folder_button.add_theme_color_override("icon_focus_color", _color * 1.25)
	_folder_button.add_theme_color_override("icon_pressed_color", _color * 1.0)
	_store_color = _color * 1.25

func _set_button_font_size() -> void:
	var _font_size: int = __c._setup_project._get_popup_text_size()
	__c._setup_settings._set_theme_override_font_size(_folder_button, _font_size)
	if _font_size > 20:
		_folder_button.expand_icon = true
	else:
		_folder_button.expand_icon = false

func _set_data_folder() -> void:
	_find_popup_panel._current_folder_dict = {
		"index": _button_index_folder,
		"parent": _store_parent,
		"name"  : _store_name,
		"color" : _store_color,
	}
	#print("data: ", _find_popup_panel._current_folder_dict)

#endregion
################################################################################
#region _get_text_column_size

func _set_name_min_size() -> void:
	var _offset: int = 15
	_folder_button.custom_minimum_size.x = _get_text_size().x + _offset

func _get_text_size() -> Vector2:
	var _font: Font = _folder_button.get_theme_font("font")
	var _font_size: int = _folder_button.get_theme_font_size("font_size")
	var _text: String = _folder_button.text
	var _text_size := _font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size)
	return _text_size

#endregion
################################################################################
#region _grab_focus_func

func _get_previous_folder_button() -> Array[SMPButtonFolder]:
	var _buttton_arr: Array[SMPButtonFolder]
	if _folder_container._item_container.get_child_count() > 0:
		for child: SMPButtonFolder in _folder_container._item_container.get_children():
			if child._button_index_folder <= _button_index_folder:
				_buttton_arr.push_back(child)
	return _buttton_arr

func _get_folder_size() -> Array[SMPButtonFolder]:
	var _buttton_arr: Array[SMPButtonFolder]
	var _size: int = _folder_container._item_container.get_children().size()
	if _size > 10:
		for child: SMPButtonFolder in _folder_container._item_container.get_children():
			_buttton_arr.push_back(child)
	return _buttton_arr

func _changeable_follow_focus() -> void:
	var _folder_size: Array[SMPButtonFolder] = _get_folder_size()
	if _button_index_folder > _folder_size[-7]._button_index_folder:
		_folder_container._scroll_container.follow_focus = false
	else:
		_folder_container._scroll_container.follow_focus = true

#endregion
################################################################################


##:: signal
################################################################################
#region _signal On_connect

func _on_button_presseed() -> void:
	if _find_popup_panel._editor_fs_dir._is_load_button:
		return
	if _find_popup_panel._current_folder_dict["index"] != _button_index_folder:
		_set_data_folder()
		_find_popup_panel._release_focus_selected_folder()
		_set_visible_focus_panel(true)
		_folder_container._get_file_subdir_select(self)

func _on_gui_input(_event: InputEvent) -> void:
	if _event is InputEventMouseButton:
		if _event.pressed and _event.button_index == MOUSE_BUTTON_RIGHT:
			_find_popup_panel._set_init_remove_selected()
			_find_popup_panel._main_container.grab_focus()

	elif _event is InputEventKey:
		if _event.pressed and _event.keycode == KEY_BACKSPACE:
			_find_popup_panel._set_init_remove_selected()

		elif _event.pressed and _event.keycode == KEY_TAB:
			_find_popup_panel._find_sc_container_first_item.call_deferred("forward")

		elif _event.pressed and _event.ctrl_pressed and _event.keycode == KEY_F:
			_find_popup_panel._set_line_edit_status("all")

		elif _event.pressed and _event.keycode == KEY_LEFT:
			if _button_index_folder != 0:
				var _previous_item: int = -2
				var _arr: Array[SMPButtonFolder] = _get_previous_folder_button()
				_arr[_previous_item]._folder_button.grab_focus.call_deferred()
				_changeable_follow_focus()
			else:
				_find_popup_panel._button_close.grab_focus.call_deferred()

	## floder_jump_select_previous
		elif _select_key_alt_jump(_event, KEY_H) or \
			_event.pressed and _event.ctrl_pressed and _event.keycode == KEY_UP:
			if _folder_button.has_focus():
				if _button_index_folder < _range_jump:
					_find_popup_panel._exist_folder_container_size(_button_index_folder)
					return
				for i in _range_jump:
					_input_event(KEY_UP)

	## floder_jump_select_next
		elif _select_key_alt_jump(_event, KEY_N) or \
			_event.pressed and _event.ctrl_pressed and _event.keycode == KEY_DOWN:
			if _folder_button.has_focus():
				var _folder_size: int = _find_popup_panel._get_exist_folder_container_size()
				var _border: int = _folder_size - _range_jump
				if _button_index_folder > _border:
					_find_popup_panel._exist_folder_container_size(
						_button_index_folder, _range_jump
						)
					return
				for i in _range_jump:
					_input_event(KEY_DOWN)

	## alt_pressed_change_path
		elif _select_key_alt_pressed(_event, KEY_L, KEY_RIGHT):
			if _folder_button.has_focus():
				_input_event(KEY_RIGHT)
				_folder_button.accept_event()

#endregion
################################################################################
##:: event_key
#region _key_input_func

func _select_key_alt_pressed( _event: InputEventKey, _key_1: Key, _key_2: Key) -> bool:
	if not _event.pressed and _event.alt_pressed and _event.keycode == _key_1 or \
		not _event.pressed and _event.keycode == _key_2:
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

#endregion
################################################################################

