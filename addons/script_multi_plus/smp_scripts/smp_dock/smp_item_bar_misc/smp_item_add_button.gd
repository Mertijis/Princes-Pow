@tool
class_name SMPItemAddButton
extends SMPItemButtonParent


var _item_bar1: SMPItemAddButton
var _item_bar2: SMPItemAddButton
var _item_bar3: SMPItemAddButton

var _timer_refocus: SMPTimerUtility

var _button_index: int = 0

var _is_add_button: bool = false


################################################################################
#region signal_ready

func _set_ready_signal() -> void:
	__c._setup_signal.connect_button_pressed(self, _on_button_pressed)

#endregion
################################################################################
#region set_button_index

func _set_ready_status() -> void:
	_timer_refocus = SMPTimerUtility.new(_dock_main)
	_item_bar1 = _dock_main._mcontainer_1._dock_item_bar._item_add_button
	_item_bar2 = _dock_main._mcontainer_2._dock_item_bar._item_add_button
	_item_bar3 = _dock_main._mcontainer_3._dock_item_bar._item_add_button
	_button_index = _get_button_index()
	_set_init_icon(_button_index)

func _get_button_index() -> int:
	var _owner: SMPDockContainer = __c._setup_utility._find_parent_dock_container(self)
	return _owner.container_index

#endregion
################################################################################
#region set_icon

func _set_init_icon(_index: int) -> void:
	match _index:
		1:
			_set_icon_settings("add")
		2:
			_set_icon_settings("add")
		3:
			_set_icon_settings("minus")

func _set_icon_settings(_type: String) -> void:
	self.icon = __c._setup_settings._icon_dict[_type]
	self.tooltip_text = __c._setup_settings._tooltip_dict[_type]
	__c._setup_settings._set_icon_alignment(self, "center")
	__c._setup_settings._set_icon_custom_min_size_x(self, __c._setup_settings._min_size_x["add"])

func _is_add_pressed() -> void:
	_is_add_button = not _is_add_button

func _get_button_state() -> bool:
	return _is_add_button

func _set_add_icon_handle() -> void:
	if not _item_bar1._is_add_button:
		_item_bar1.icon = __c._setup_settings._icon_dict["add"]
		_item_bar1.tooltip_text = __c._setup_settings._tooltip_dict["add"]
	else:
		_item_bar1.icon = __c._setup_settings._icon_dict["minus"]
		_item_bar1.tooltip_text = __c._setup_settings._tooltip_dict["minus"]

#endregion
################################################################################

##\\ handle
################################################################################
#region handle_button

func _set_add_handle(_key_index: int = -1, _load_set: bool = false) -> void:
	if _key_index != -1:
		_button_index = _key_index
		_is_add_button = _load_set
	_process_button_state()

func _process_button_state() -> void:
	match _button_index:
		1:
			if not _item_bar1._is_add_button:
				_hide_container_status(2)
				_container_state_1(false)
				_remove_change_focus(1, 2)
			else:
				_container_state_1(true)
				_item_bar2.set_visible(false)
				_dock_main._mcontainer_2._set_notepad_grab_focus()
			_set_add_icon_handle()
		2:
			_container_state_2(_is_add_button)
			_dock_main._mcontainer_3._set_notepad_grab_focus()
		3:
			if _item_bar3._is_add_button:
				_hide_container_status(3)
			_container_state_2(false)
			_remove_change_focus(2, 3)
			_dock_main._mcontainer_2._set_notepad_grab_focus()

	if _plugin == null or _plugin._is_once_call:
		if _dock_main._mcontainer_2._vbox.get_child_count() == 0:
			_container_state_1(false)

		if _dock_main._mcontainer_3._vbox.get_child_count() == 0:
			_container_state_2(false)
		else:
			_container_state_2.call_deferred(true)

#endregion
################################################################################
#region change_focus

func _remove_change_focus(_forigin: int, _ftarget: int) -> void:
	if _plugin == null or _plugin._is_once_call:
		return
	var _mcont_origin := _dock_main._get_focus_mcontainer(_forigin)
	var _mcont_target := _dock_main._get_focus_mcontainer(_ftarget)
	var _scte := _dock_main._get_focus_scte_dict(_ftarget)
	var _path: String = _scte.get("script_path", "")

	if _mcont_origin._code_edit != null:
		_mcont_origin._code_edit.grab_focus()

		if _mcont_target._vbox.get_child_count() > 0:
			__c._setup_settings._remove_theme_override_panel_focus(_mcont_origin._code_edit)

	if _mcont_origin._rich_text != null:
		_mcont_origin._rich_text.grab_focus()
	if _mcont_origin._te_cedit != null:
		_mcont_origin._te_cedit.grab_focus()

	_dock_main._set_is_remove_script(true)
	await _dock_main.get_tree().process_frame

	_mcont_target._change_to_return_container()

	if _path != "":
		_dock_main._handle_closed_script(_path)
	else:
		_dock_main._closed_container(_ftarget)

	_timer_refocus._set_timer_start_auto(
		0.6, 1, 1, _on_timer_refocus.bind(_mcont_origin, _forigin)
		)

func _on_timer_refocus(_mcont_origin: SMPDockContainer, _forigin: int) -> void:
	_timer_refocus._init_timeout_auto()
	if _mcont_origin._code_edit != null:
		_mcont_origin._code_edit.grab_focus()

	if _mcont_origin._rich_text != null:
		_mcont_origin._rich_text.grab_focus()
	elif _mcont_origin._te_cedit != null:
		_mcont_origin._te_cedit.grab_focus()

	_dock_main._store_focus_index = _forigin

#endregion
################################################################################
#region change_state

func _container_state_1(_active: bool) -> void:
	_dock_main._dock_split2.set_visible(_active)
	_item_bar1._is_add_button = _active
	_dock_main._mcontainer_1._set_add_state(_is_add_button)
	if _active:
		await _dock_main.get_tree().process_frame
		if _dock_main._mcontainer_2._code_edit != null:
			_dock_main._mcontainer_2._code_edit.grab_focus.call_deferred()

func _container_state_2(_active: bool) -> void:
	_item_bar1.set_visible(not _active)
	if _dock_main._mcontainer_2._vbox.get_child_count() > 0:
		_item_bar2.set_visible(not _active)
	else:
		_item_bar2.set_visible(false)

	if not _plugin._is_once_call:
		if _dock_main._mcontainer_2.is_visible():
			_item_bar1._is_add_button = true
			_set_add_icon_handle()

	_item_bar2._is_add_button = _active
	_dock_main._mcontainer_3.set_visible(_active)
	_dock_main._mcontainer_2._set_add_state(_item_bar2._is_add_button)

func _hide_container_status(_findex: int) -> void:
	var _mcont := _dock_main._get_focus_mcontainer(_findex)
	var _recent_menu := _mcont._get_recent_menu_item()
	_recent_menu._store_menu_index = -1
	_recent_menu._set_init_button_checked()
	if _recent_menu._get_vbox_child_item_count() > 2:
		_recent_menu._saving_menu_index(-1)

#endregion
################################################################################
#region signal On_connect

func _on_button_pressed() -> void:
	_is_add_pressed()
	_set_add_handle()
	#prints("on_add_button: ", _button_index)

#endregion
################################################################################



