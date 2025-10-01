@tool
class_name SMPButtonOpen
extends Button


@export_enum("ATTACH_1", "ATTACH_2", "ATTACH_3") var _button_open: String = "ATTACH_1"

""" class """
var __c: SMPClassManagers
var _debug_manager: SMPDebugManager
var _dock_main: ScriptMultiPlusDock
var _find_popup_panel: SMPFindPopupPanel

var _timer_opened_sc: SMPTimerUtility

var _store_path: String
var _focus_case: int = -1


##:: setup
################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item
			elif item is ScriptMultiPlusDock:
				_dock_main = item
			elif item is SMPDebugManager:
				_debug_manager = item
			elif item is SMPFindPopupPanel:
				_find_popup_panel = item

	_timer_opened_sc = SMPTimerUtility.new(_dock_main)

	_set_status()
	_set_ready_signal()

#endregion
################################################################################
#region _signal_connect

func _set_ready_signal() -> void:
	__c._setup_signal.connect_button_pressed(self, _on_button_pressed)
	__c._setup_signal.connect_gui_input(self, _on_gui_input)

#endregion
################################################################################


##:: status
################################################################################
#region _setget

func _get_sc_global_names(_path: String) -> Array[String]:
	var _sc := load(_path)
	if _sc is GDScript:
		var _sc_name: String = _path.get_file()
		var _global_name: String = _sc.get_global_name()
		return [_global_name, _sc_name]
	return []

func _get_create_uid_path(_path: String) -> String:
	return __c._saveload_filesystem._get_uid_path(_path)

#endregion
################################################################################
#region _set_button_status

func _set_store_path(_path: String) -> void:
	_store_path = _path

func _set_status() -> void:
	var _label_text: String
	match _button_open:
		"ATTACH_1":
			_label_text = __c._setup_settings._text_dict["attach_1"]
		"ATTACH_2":
			_label_text = __c._setup_settings._text_dict["attach_2"]
		"ATTACH_3":
			_label_text = __c._setup_settings._text_dict["attach_3"]
	self.text = _label_text
	self.custom_minimum_size.x = __c._setup_settings._min_size_x["btn_bot"]

#endregion
################################################################################


##:: handle
################################################################################
#region _pressed_open

func _open_script(_path: String) -> void:
	var _res: Resource = ResourceLoader.load(_path)
	if _res is GDScript:
		_dock_main._set_is_opened_script(true)
		EditorInterface.edit_script(_res)
		_timer_opened_sc._set_timer_start_auto(0.2, 1, 1, _on_timeout_opened_sc)
		_debug_opened_log([_path], "122")

	else:
		_debug_opened_err_log([_store_path], "125")

func _open_attached(_container_index: int) -> void:
	if _store_path != "":
		match _container_index:
			1:
				_checked_expand_setter(_container_index, [1, 0, 0])
				_open_script(_store_path)

			2:
				_checked_expand_setter(_container_index, [0, 1, 0])
				_open_script(_store_path)
				_dock_main._dock_split2.set_visible(true)

				if not _dock_main._mcontainer_1._get_add_button_state():
					await get_tree().process_frame
					_dock_main._mcontainer_1._dock_item_bar._item_add_button.pressed.emit()

			3:
				_checked_expand_setter(_container_index, [0, 0, 1])
				_open_script(_store_path)

				if not _dock_main._mcontainer_2._get_add_button_state():
					await get_tree().process_frame
					_dock_main._mcontainer_2._dock_item_bar._item_add_button.pressed.emit()

func _checked_expand_setter(_container_index: int, _select: Array) -> void:
	if _dock_main._store_focus_index != _container_index:
		if _dock_main._is_distract_button:
			__c._split_utility._change_dock_split_vert_button_D()
		else:
			__c._item_exp_setter._change_expand_split_offset("ret", "", _select)
		__c._item_exp_setter._set_defualt_unfocus_expand()
		__c._item_exp_setter._set_focus_expand_selected([1, 1, 1])

func _on_timeout_opened_sc() -> void:
	var _tabcont := __c._plugin._tab_container
	_timer_opened_sc._init_timeout_auto()
	_dock_main._update_container_list()
	_dock_main._set_is_opened_script(false)
	_dock_main._event_button_num = 0
	_dock_main._store_focus_index = _focus_case
	_tabcont.tab_changed.emit(_tabcont.current_tab)

#endregion
################################################################################


##:: signal
################################################################################
#region _signal On_connect

func _on_button_pressed() -> void:
	match _button_open:
		"ATTACH_1":
			var _cnt_index: int = 1
			_dock_main._store_focus_index = _cnt_index
			_focus_case = _cnt_index
			_open_attached(_cnt_index)
			_find_popup_panel.set_visible(false)
			_find_popup_panel._set_init_opend_button.call_deferred()

		"ATTACH_2":
			var _cnt_index: int = 2
			_focus_case = _cnt_index
			_dock_main._store_focus_index = _cnt_index
			_open_attached(_cnt_index)
			_find_popup_panel.set_visible(false)
			_find_popup_panel._set_init_opend_button.call_deferred()

		"ATTACH_3":
			var _cnt_index: int = 3
			_focus_case = _cnt_index
			_dock_main._store_focus_index = _cnt_index
			_open_attached(_cnt_index)
			_find_popup_panel.set_visible(false)
			_find_popup_panel._set_init_opend_button.call_deferred()

#endregion
################################################################################
#region _sig gui_input

func _on_gui_input(_event: InputEvent) -> void:
	if _event is InputEventKey:
		if _select_not_key_alt_pressed(_event, KEY_I, KEY_UP):
			if not _find_popup_panel._is_selected:
				_find_popup_panel._find_sc_container_first_item.call_deferred("reverse")
			else:
				_find_popup_panel._get_selected_sc_item.call_deferred()

		elif _event.pressed and _event.keycode == KEY_F:
			_find_popup_panel._set_line_edit_status("all")

		elif _select_not_key_alt_pressed(_event, KEY_J, KEY_LEFT):
			_find_popup_panel._main_container.gui_input.emit(_event)

		elif _select_not_key_alt_pressed(_event, KEY_L, KEY_RIGHT):
			_find_popup_panel._main_container.gui_input.emit(_event)

#endregion
################################################################################
#region _sig event_key

func _select_not_key_alt_pressed( _event: InputEventKey, _key_1: Key, _key_2: Key) -> bool:
	if _event.pressed and _event.alt_pressed and _event.keycode == _key_1 or \
		_event.pressed and _event.keycode == _key_2:
		return true
	return false

#endregion
################################################################################


##:: debug
################################################################################
#region __notif

func _debug_opened_log(_vari: Array, _line: String) -> void:
	if not _debug_manager._script_opened:
		return
	_debug_manager._log_signal("pri", self, "script_opened", _vari, _line)

func _debug_opened_err_log(_vari: Array, _line: String) -> void:
	var _log: String = "Failed loading path data. Error loading file"
	_debug_manager._err_open_debug_log("err", self, _log, _vari, _line)

#endregion


