@tool
class_name SMPDockInput
extends Control


""" class """
var __c: SMPClassManagers
var _plugin: ScriptMultiPlusPlugin
var _dock_main: ScriptMultiPlusDock
var _timer_shift: SMPTimerUtility
var _timer_alt: SMPTimerUtility

var _store_click_word: String
var _pressed_count_alt: int = 0


var _find_replace_bar: Node:
	set(_value):
		_find_replace_bar = _value
	get:
		return _find_replace_bar


##:: setup
################################################################################
#region set_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is ScriptMultiPlusPlugin:
				_plugin = item
			elif item is ScriptMultiPlusDock:
				_dock_main = item
			elif item is SMPClassManagers:
				__c = item
			elif item.is_class("FindReplaceBar"):
				_find_replace_bar = item

	_timer_alt = SMPTimerUtility.new(_dock_main)
	_timer_shift = SMPTimerUtility.new(_dock_main)

#endregion
################################################################################
#region _utility

func _get_focus_container() -> SMPDockContainer:
	for cont in _dock_main._get_mcontainer_arr():
		if _dock_main._store_focus_index == cont.container_index:
			return cont
	return null

func _check_type_vbox_children() -> bool:
	var _cont := _dock_main._get_focus_mcontainer(_dock_main._store_focus_index)
	if _cont._vbox.get_child_count() > 0:
		if _cont._vbox.get_child(0) is not VSplitContainer:
			return true
	return false

func _get_shortcut_list() -> Array:
	return EditorInterface.get_editor_settings().get_setting("shortcuts") as Array

func _get_key_label(_event: InputEventKey) -> Key:
	return DisplayServer.keyboard_get_label_from_physical(_event.physical_keycode)

#endregion
################################################################################


##:: signal gui_input
################################################################################
#region sig_gui_input

func _on_gui_input(_event: InputEvent) -> void:
	if _dock_main == null:
		return

	if _event is InputEventMouseButton:
		if _event.double_click and _event.button_index == MOUSE_BUTTON_LEFT:
			if _dock_main._get_list_text():
				var _select_word: String = _dock_main.code_edit.get_word_under_caret()
				if _dock_main._store_focus_index != -1:
					_store_click_word = _select_word

				## color_off
				var _walpha: float = __c._setup_project._get_text_word_alpha()
				if _walpha <= 0.0:
					return

				if _find_replace_bar.is_visible():
					return

				if __c._find_word_tools._find_exist_is_region_line(_dock_main.code_edit):
					__c._find_word_tools._find_set_region_line(_dock_main.code_edit)
					return
				__c._find_word_tools._find_word_changed_color(_dock_main.code_edit)
				_dock_main.code_edit.select_word_under_caret()
				return


	if _event is InputEventKey:
		var _inputkeys: Dictionary = __c._setup_project._inputkey_dict

	## move_caret_moultiply_up
		if _event.pressed and _event.is_match(_inputkeys["TextScrollUp"]):
			_dock_main._caret_changed_position()
			if _dock_main.code_edit != null:
				__c._scroll_caret_calc._set_caret_scroll_multiply(
					-1, _dock_main._vscroll_value, _dock_main.code_edit
					)
				if __c._setup_project._get_center_caret_on_scroll():
					_dock_main.code_edit.center_viewport_to_caret()


	## move_caret_moultiply_down
		elif _event.pressed and _event.is_match(_inputkeys["TextScrollDown"]):
			_dock_main._caret_changed_position()
			if _dock_main.code_edit != null:
				__c._scroll_caret_calc._set_caret_scroll_multiply(
					1, _dock_main._vscroll_value, _dock_main.code_edit
					)
				if __c._setup_project._get_center_caret_on_scroll():
					_dock_main.code_edit.center_viewport_to_caret()

	## finder_panel
		elif not _event.pressed and _event.keycode == KEY_ALT:
			if _timer_alt._set_timer_start_pressed(0.4, 2, 1):
				_dock_main._on_visible_popup_panel()

	## find_word
		elif not _event.pressed and _event.keycode == KEY_SHIFT:
			if _timer_shift._set_timer_start_pressed(0.4, 2, 1):
				if __c._find_word_tools._find_exist_is_region_line(_dock_main.code_edit):
					__c._find_word_tools._find_set_region_line(_dock_main.code_edit)
					return
				__c._find_word_tools._find_word_changed_color(_dock_main.code_edit)


		elif _event.pressed and _event.keycode == KEY_ESCAPE:
			__c._find_word_tools._find_init_color(_dock_main.code_edit)


		elif _event.pressed and _event.is_match(_inputkeys["JumpPrevious"]):
			__c._find_word_tools._jump_previous_for_selected_word(_dock_main.code_edit)
			_dock_main.code_edit.center_viewport_to_caret()


		elif _event.pressed and _event.is_match(_inputkeys["JumpNext"]):
			__c._find_word_tools._jump_next_for_selected_word(_dock_main.code_edit)
			_dock_main.code_edit.center_viewport_to_caret()


		elif _event.pressed and _event.is_match(_inputkeys["OpenRecent"]):
			var _cont := _get_focus_container()
			if _cont:
				if not _cont._get_recent_menu_item()._is_visible_recent_panel():
					_cont._get_recent_menu_item().pressed.emit()
					_cont._get_recent_menu_item()._set_focus_item()


		elif _event.pressed and (_event.ctrl_pressed or _event.meta_pressed) and _event.keycode == KEY_F:
			if _check_type_vbox_children():
				return
			_dock_main._find_replace_line_edit.text = _store_click_word
			_dock_main._find_replace_line_edit.text_changed.emit(_store_click_word)

#endregion
################################################################################


##:: setting
################################################################################
#region event_shortcut_sett

func _get_event_close_shortcut(_item_name: String) -> InputEventKey:
	var _inputk := InputEventKey.new()

	for i in range(_plugin._script_list_popup_menu.item_count):

		var _item: String = _plugin._script_list_popup_menu.get_item_text(i)

		if _item == _item_name:
			var _shortcut := _plugin._script_list_popup_menu.get_item_shortcut(i)

			for _e: InputEventKey in _shortcut.events:
				_inputk.pressed = true
				_inputk.echo = _e.echo
				_inputk.keycode = _e.keycode
				_inputk.location = _e.location
				_inputk.alt_pressed = _e.alt_pressed
				_inputk.ctrl_pressed = _e.ctrl_pressed
				_inputk.meta_pressed = _e.meta_pressed
				_inputk.shift_pressed = _e.shift_pressed
				_inputk.physical_keycode = _e.physical_keycode

			#print("event: ", _shortcut.events)
			return _inputk

	return null

#endregion
################################################################################
#region event_change_assign

func _boot_eventkey_shortcuts() -> void:
	if _dock_main._event_close == null:
		_dock_main._event_close = _get_event_close_shortcut("Close")
	if _dock_main._event_close_all == null:
		_dock_main._event_close_all = _get_event_close_shortcut("Close All")
	if _dock_main._event_close_other_tabs == null:
		_dock_main._event_close_other_tabs = _get_event_close_shortcut("Close Other Tabs")
	if _dock_main._event_close_docs == null:
		_dock_main._event_close_docs = _get_event_close_shortcut("Close Docs")

#endregion
################################################################################

