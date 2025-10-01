@tool
class_name ScriptMultiPlusDock
extends MarginContainer


@export var _debug_manager: SMPDebugManager

""" class """
var __c: SMPClassManagers
var _plugin: ScriptMultiPlusPlugin
var _event_dock_input: SMPDockInput
var _setup_signal: ScriptMultiPlusSignal
var _dock_order_trees: SMPDockOrderTrees
var _doc_helper: SMPDocumentHelper

""" timer """
var _timer_file_moved: SMPTimerUtility
var _timer_file_removed: SMPTimerUtility
var _timer_distruct_button: SMPTimerUtility

var _sc_head_popup_menu: PopupMenu
var _script_item_list: ItemList
var _find_replace_line_edit: LineEdit
var _container_list_dict: Dictionary


var code_edit: CodeEdit:
	set(_value):
		code_edit = _value
		if code_edit != null:
			var _vscroll: VScrollBar = code_edit.get_v_scroll_bar()
			_vscroll_value = round(_vscroll.value)
		_script_ebase = __c._setup_utility._get_script_editor().get_current_editor()
	get:
		return code_edit

var _tree_file_dock: Tree:
	set(_value):
		_tree_file_dock = _value

""" doc_item """
var _script_ebase: ScriptEditorBase
var _document_dict: Dictionary
var _is_open_doc: bool = false


""" vscroll_bar """
var _vscroll_value: float ## event_input


""" event """
var _event_close: InputEventKey
var _event_close_all: InputEventKey
var _event_close_other_tabs: InputEventKey
var _event_close_docs: InputEventKey

""" store """
var _store_tab_index: int
var _store_script_path: String
var _store_script_path_uid: String
var _store_load_path: Array[String] # filesystem
var _store_load_data: Dictionary # filesystem
var _store_name_hover_item: String = ""

var _store_focus_index: int = 1
var _event_button_num: int = -1
var _save_key: Dictionary


""" bools """
var _is_tab_changed: bool = false
var _is_close_all: bool = false

var _is_opened_script: bool = false
var _is_closed_script: bool = false
var _is_remove_script: bool = false
var _is_exited_misc: bool = false

var _is_closed_doc: bool = false
var _is_empty_boot: bool = false
var _is_file_removed: bool = false

var _is_unloaded_data: bool = false
var _is_distract_button: bool = false
var _is_plugin_actived: bool = false


""" onready """
@onready var _dock_split: SplitContainer = %DockSplit
@onready var _dock_split2: SplitContainer = %DockSplit2

@onready var _mcontainer_1: SMPDockContainer = %MContainer1
@onready var _mcontainer_2: SMPDockContainer = %MContainer2
@onready var _mcontainer_3: SMPDockContainer = %MContainer3

@onready var _find_popup_panel: SMPFindPopupPanel = %ScriptFindPopupPanel


##:: setup
################################################################################
#region _set_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is ScriptMultiPlusPlugin:
				_plugin = item
			elif item is SMPClassManagers:
				__c = item
			elif item is ScriptMultiPlusSignal:
				_setup_signal = item
			elif item is ItemList:
				_script_item_list = item
			elif item is LineEdit:
				_find_replace_line_edit = item
			elif item is SMPDockInput:
				_event_dock_input = item
			elif item is SMPDockOrderTrees:
				_dock_order_trees = item
			elif item is SMPDocumentHelper:
				_doc_helper = item

	_sc_head_popup_menu = _plugin._script_menu_button.get_popup()
	_save_key = __c._setup_settings._save_key_name

	_timer_file_moved = SMPTimerUtility.new(self)
	_timer_file_removed = SMPTimerUtility.new(self)
	_timer_distruct_button = SMPTimerUtility.new(self)

func _setup_mcontainer_class(_setup_arr: Array) -> void:
	var _dock_code_arr := _get_mcontainer_arr()
	for dock: SMPDockContainer in _dock_code_arr:
		dock._setup_class(_setup_arr)

#endregion
################################################################################
#region _visible_popup_panel

func _on_visible_popup_panel() -> void:
	_find_popup_panel._get_recent_list_data()
	_find_popup_panel._get_sc_list_items()
	_find_popup_panel._get_sc_curr_items()
	_find_popup_panel._set_open_popup_panel(self)

#endregion
################################################################################


##:: set_ready
################################################################################
#region _ready_status

func _ready() -> void:
	if _setup_signal != null:
		_setup_ready_status()
		_set_ready_signal.call_deferred()

func _setup_ready_status() -> void:
	_caret_changed_position()
	_store_script_path = _get_script_path()
	_store_script_path_uid = _get_script_path_uid()
	_change_ready_code_edit_position()
	_update_container_list()
	_script_item_list.allow_reselect = true

func _set_thick_size() -> void:
	var _thick_size: int = __c._setup_settings._grab_thick_size
	__c._setup_settings._set_theme_override_min_grab_thick(_dock_split, _thick_size, false)
	__c._setup_settings._set_theme_override_min_grab_thick(_dock_split2, _thick_size, false)

#endregion
################################################################################
#region _ready_signal

func _set_ready_signal() -> void:
	__c._setup_signal.connect_gui_input(_script_item_list, _on_gui_input_item_list)
	__c._setup_signal.connect_script_closed(_plugin._script_editor, _on_script_closed)
	__c._setup_signal.connect_files_moved(_plugin._filesystem_dock, _on_files_moved)
	__c._setup_signal.connect_files_removed(_plugin._filesystem_dock, _on_file_removed)
	__c._setup_signal.connect_window_input(
		_sc_head_popup_menu, _on_window_input_sc_head_popup_menu
		)
	__c._setup_signal.connect_window_input(
		_plugin._script_list_popup_menu, _on_window_input_sc_list_popup_menu
		)
	__c._setup_signal.connect_drag_ended(_dock_split, __c._split_utility._on_dock_split_1HV_drag_ended)
	__c._setup_signal.connect_drag_ended(_dock_split2, __c._split_utility._on_dock_split_2HV_drag_ended)
	__c._setup_signal.connect_drag_started(_dock_split, __c._split_utility._on_dock_split_1HV_drag_started)
	__c._setup_signal.connect_drag_started(_dock_split2, __c._split_utility._on_dock_split_2HV_drag_started)

	__c._setup_signal.connect_line_edit_text_changed(_find_replace_line_edit, _on_line_edit_text_changed)
	__c._setup_signal.connect_button_toggled(_plugin._editor_distract_button, _on_distract_button_pressed)
	__c._setup_signal.connect_visibility_changed(_plugin._script_editor_window, _on_floating_visibility)
	__c._setup_signal.connect_visibility_changed(_plugin._editor_help_search, _on_visibility_changed_ehelp)


func _set_signal_lazy() -> void:
	__c._setup_signal.connect_tab_changed(_plugin._tab_container, _on_tab_changed)
	__c._setup_signal.connect_child_order_changed(_plugin._tab_container, _on_tab_cont_child_order_changed)
	__c._setup_signal.connect_child_entered_tree(_plugin._tab_container, _on_tab_cont_child_entered_tree)
	__c._setup_signal.connect_child_exiting_tree(_plugin._tab_container, _on_tab_cont_child_exiting_tree)
	__c._split_utility._set_half_split_offset()
	_caret_changed_position()
	_set_thick_size()
	_event_dock_input._boot_eventkey_shortcuts()
	__c._find_word_script_tools._get_words_from_script(code_edit)

	if _plugin._editor_distract_button.button_pressed:
		_is_distract_button = true

	if _mcontainer_1._vbox.get_child_count() > 0:
		await get_tree().process_frame
		_boot_focus_loaded_script.call_deferred()
		_mcontainer_1._set_rich_text_item(_mcontainer_1._scte_dict["sc_name"])
	else:
		_mcontainer_1._set_notepad_grab_focus()
		_mcontainer_1._notepad_container._code_notepad.focus_entered.emit()
	_empty_selected()

## used_error_floating
func _on_floating_visibility() -> void:
	if _plugin._script_editor_window.visible:
		if EditorInterface.is_plugin_enabled("script_multi_plus"):
			EditorInterface.set_plugin_enabled("script_multi_plus", false)
			EditorInterface.set_plugin_enabled("script_multi_plus", true)
		if EditorInterface.is_plugin_enabled("script_region_folder"):
			EditorInterface.set_plugin_enabled("script_region_folder", false)
			EditorInterface.set_plugin_enabled("script_region_folder", true)

#endregion
################################################################################
#region _ready_boot

func _boot_focus_loaded_script() -> void:
	for dict: Dictionary in _get_scte_arr():
		var _index: int = dict.get("focus_index", -1)
		var _tb_index: int = dict.get("tab_index", -1)
		var _vsplit := dict.get("parent")

		if _index == 1:
			_store_focus_index = 1
			_script_item_list.item_selected.emit(_tb_index)
			return

func _set_boot_not_list(_cont: SMPDockContainer) -> void:
	if _cont != null:
		_cont.set_visible(true)
		_cont._set_visible_notepad(true)
		_deselect_sc_list()
		_is_unloaded_data = true

func _set_boot_empty() -> void:
	if _is_empty_boot:
		_mcontainer_1.set_visible(true)
		_mcontainer_1._set_visible_notepad(true)
		_set_is_empty_boot(false)

func _set_first_boot_save_data() -> void:
	if not __c._godot_conf.has_section_key(__c._setup_settings._section, "index_1"):
		var _ftype: int = __c._setup_project._get_focus_flash_type()
		_mcontainer_1._scte_dict["script_path"] = _store_script_path
		_mcontainer_1._scte_dict["uid_path"] = _store_script_path_uid
		__c._setup_settings._set_theme_override_panel_focus(code_edit, _ftype)
		__c._saveload_conf._save_parameter(_store_focus_index, _mcontainer_1._scte_dict)
		push_warning("initial_boot_saving")

func _change_ready_code_edit_position() -> void:
	if not __c._godot_conf.has_section_key(__c._setup_settings._section, "index_1"):
		if code_edit != null:
			if _check_exs_curr_sc_name(code_edit) != -1:
				if _mcontainer_1._vbox.get_child_count() == 0:
					_mcontainer_1._scte_dict = _plugin._get_parent_code_edit_container(code_edit)
					_mcontainer_1._scte_dict.get("parent", "").reparent(_mcontainer_1._vbox)
					__c._setup_settings._set_container_flag(_plugin._tab_container, "fill")
					code_edit.grab_focus.call_deferred()
					_set_first_boot_save_data()
					_store_focus_index = 1
			else:
				if _mcontainer_1._vbox.get_child_count() == 0:
					_set_is_empty_boot(true)
		else:
			if _mcontainer_1._vbox.get_child_count() == 0:
				_set_is_empty_boot(true)

func _check_exs_curr_sc_name(_ce: CodeEdit) -> int:
	var _current_sc: Dictionary = _plugin._get_parent_code_edit_container(code_edit)
	var _match: int = 0
	for idx in __c._saveload_conf._indexs:
		var _data: Dictionary = __c._saveload_conf._get_save_data(idx)
		for _key_int: int in _data:
			var _sc_name: Array = _data[_key_int].get("sc_name", [])
			var _curr_sc_name: Array = _current_sc.get("sc_name", [])
			if not _sc_name.is_empty() and not _curr_sc_name.is_empty():
				if _curr_sc_name[1] == _sc_name[1]:
					_match = -1
	return _match

## initialize_boot
func _empty_selected() -> void:
	if _plugin._tab_container.current_tab == -1:
		_mcontainer_1.set_visible(true)
		_mcontainer_1._dock_item_bar.set_visible(true)
		_mcontainer_2._dock_item_bar.set_visible(true)
		_mcontainer_3._dock_item_bar.set_visible(true)
		_mcontainer_1._notepad_container.set_visible(true)

#endregion
################################################################################


##:: status
################################################################################
#region set_status

func _caret_changed_position() -> void:
	if _get_list_text():
		code_edit = _setget_code_edit("get")
		_check_is_connected("connect")

func _set_scroll_past_end() -> void:
	if code_edit != null:
		var _past_end: bool = __c._setup_project._get_scroll_past_end_of_file()
		code_edit.scroll_past_end_of_file = _past_end
		_mcontainer_1._notepad_container._set_past_end(_past_end)
		_mcontainer_2._notepad_container._set_past_end(_past_end)
		_mcontainer_3._notepad_container._set_past_end(_past_end)

func _update_container_list() -> void:
	_container_list_dict.clear()
	var _container_children: Array[Node] = _plugin._tab_container.get_children()
	for child: Node in _container_children:
		_container_list_dict[child.name] = child

func _set_init_stat() -> void:
	#_plugin._tab_container.deselect_enabled = true
	#_plugin._tab_container.current_tab = -1
	_store_tab_index = -1
	_event_button_num = 0

func _set_is_opened_script(_active: bool) -> void:
	_is_opened_script = _active

func _set_is_closed_script(_active: bool) -> void:
	_is_closed_script = _active

func _set_is_remove_script(_active: bool) -> void:
	_is_remove_script = _active

func _set_is_exited_misc(_active: bool) -> void:
	_is_exited_misc = _active

func _set_is_open_doc(_active: bool) -> void:
	_is_open_doc = _active

func _set_is_empty_boot(_active: bool) -> void:
	_is_empty_boot = _active

func _set_is_file_removed(_active: bool) -> void:
	_is_file_removed = _active

func _set_is_close_all(_active: bool) -> void:
	_is_close_all = _active

#endregion
################################################################################


##:: dock_split
################################################################################
#region dsplit

func _change_vertical_status(_is_vert: bool, _index: int) -> void:
	match _index:
		2:
			_dock_split.vertical = _is_vert

			if not _is_distract_button:
				__c._split_utility._change_dock_split_1_vert_button(_is_vert)
			else:
				__c._split_utility._change_dock_split_vert_button_D()
		3:
			_dock_split2.vertical = _is_vert

			if not _is_distract_button:
				__c._split_utility._change_dock_split_2_vert_button(_is_vert)
			else:
				__c._split_utility._change_dock_split_vert_button_D()

#endregion
################################################################################
#region dsplit_distract_free_mode

func _on_timeout_distruct_pressed(_is_distruct: bool) -> void:
	_timer_distruct_button._init_timeout_auto()
	if _is_distract_button:
		__c._split_utility._change_dock_split_vert_button_D()
	else:
		__c._split_utility._change_dock_split_vert_button_D("")

#endregion
################################################################################


##:: utility
################################################################################
#region setget_sc_utility

func _setget_code_edit(_type: String) -> CodeEdit:
	match _type:
		"get":
			return __c._setup_utility._get_code_edit()
		"null":
			return null
		_:
			push_warning("[ScriptMultiPlusDock]: Not match name: %s" % _type)
	return code_edit

func _get_list_text() -> bool:
	if _script_item_list.item_count > 0:
		if not _script_item_list.get_selected_items().is_empty():
			var _index: int = _script_item_list.get_selected_items()[0]
			var _list_name: String = _script_item_list.get_item_text(_index)

			if _list_name.get_extension() == "gd":
				return true
			elif _list_name.get_extension() == "gd(*)":
				return true
	return false

func _get_script_name(_tab_index: int) -> Array[String]:
	if not _script_item_list.get_selected_items().is_empty():
		if _get_list_text():
			var _split: PackedStringArray
			var _class_name: String
			var _list_name: String = _script_item_list.get_item_text(_tab_index)
			var _sc_current: GDScript = _plugin._script_editor.get_current_script()

			if _sc_current != null:
				_class_name = _sc_current.get_global_name()
			if _list_name.contains("(*)"):
				_split = _list_name.rsplit("(")
			if not _split.is_empty():
				_list_name = _split[0]

			return [_class_name, _list_name]
	return []

func _get_script_path() -> String:
	var _sc_current: Script = _plugin._script_editor.get_current_script()
	if _sc_current == null:
		return ""
	#print("current: ", _sc_current.resource_path)
	return _sc_current.resource_path

func _get_script_path_uid() -> String:
	var _sc_current: Script = _plugin._script_editor.get_current_script()
	if _sc_current == null:
		return ""
	var _uid_path: String = __c._saveload_filesystem._get_uid_path(_sc_current.resource_path)
	#prints("current: ", _uid_path, _sc_current.resource_path)
	return _uid_path

func _set_tooltip_item_bars() -> void:
	var _shrt_names: Array[String] = ["Focus_1", "Focus_2", "Focus_3"]
	var _inputkeys: Dictionary = __c._setup_project._inputkey_dict

	for f in _shrt_names:
		var _fint: int = f.to_int()
		var _cont := _get_focus_mcontainer(_fint)

		var _ikey:InputEventKey = _inputkeys[f]
		var _key_text: String = _ikey.as_text_keycode()
		var _ex_tooltip: String = __c._setup_settings._tooltip_dict["expand"] % _key_text
		_cont._set_expand_button_tooltip(_ex_tooltip)

	for cont in _get_mcontainer_arr():
		var _ikey:InputEventKey = _inputkeys["OpenRecent"]
		var _key_text: String = _ikey.as_text_keycode()
		var _rc_tooltip: String = __c._setup_settings._tooltip_dict["recent"] % _key_text
		cont._set_recent_menu_tooltip(_rc_tooltip)

	__c._setup_project._set_project_settings_code_edit_shortcuts()

#endregion
################################################################################


##:: signal filesystem
################################################################################
#region sig files_moved

func _on_files_moved(_old_file: String, _new_file: String) -> void:
	if _old_file.get_extension() == "gd":
		_set_is_close_all(false)
		var _index_keys: Array[String] = __c._saveload_conf._indexs
		#prints("files_moved_dock: ", _old_file, _new_file)

		__c._saveload_filesystem._handle_files_moved(
			_old_file, _new_file, _index_keys, -1
			)
		_timer_file_moved._set_timer_start_auto(
			0.1, 1, 1, _on_timeout_files_moved
			)

func _on_timeout_files_moved() -> void:
	_timer_file_moved._init_timeout_auto()
	## reselect_recent_menu
	for cont: SMPDockContainer in _get_mcontainer_arr():
		var _recent := cont._get_recent_menu_item()
		_recent._reselect_after_moved()

#endregion
################################################################################
#region sig file_removed

func _on_file_removed(_remove_file: String) -> void:
	if _remove_file.get_extension() == "gd":
		_set_is_close_all(false)
		_set_is_file_removed(true)
		var _index_keys: Array[String] = __c._saveload_conf._indexs
		var _rkeys: Array[String] = __c._saveload_conf._recent_keys
		#print("on_file_removed_dock_main: ", _remove_file)

		## to_container
		for i in _get_mcontainer_arr():
			__c._saveload_filesystem._handle_file_removed(
				_remove_file, _index_keys, -1
				)
		## to_recent_data
		for cont: SMPDockContainer in _get_mcontainer_arr():
			var _recent := cont._get_recent_menu_item()
			__c._saveload_filesystem._handle_file_removed(
				_remove_file, _rkeys, _recent._button_index
				)

		_timer_file_removed._set_timer_start_auto(
			0.1, 1, 1, _on_timeout_file_removed.bind(_remove_file)
			)

func _on_timeout_file_removed(_remove_file: String) -> void:
	_timer_file_removed._init_timeout_auto()
	## reselect_recent_menu
	for cont: SMPDockContainer in _get_mcontainer_arr():
		var _recent := cont._get_recent_menu_item()
		_recent._reselect_after_removed()

	_set_is_file_removed(false)
	_set_is_closed_script(false)
	__c._saveload_filesystem._init_item_dict.call_deferred()

#endregion
################################################################################


##:: child_ordering
################################################################################
#region sig_ ordering

func _on_tab_cont_child_order_changed() -> void:
	_dock_order_trees._moved_script_order.call_deferred()
	_debug_system_log("order_changed", ["..."], "507")

func _on_tab_cont_child_entered_tree(_entered_node: Node) -> void:
	if _is_plugin_actived:
		return
	_debug_system_log("entered_node", [_entered_node], "510")

	if _entered_node.name.begins_with("_"):
		_set_is_open_doc(true)

	if _is_opened_script:
		return
	_set_is_close_all(false)
	_set_is_opened_script(true)
	await get_tree().process_frame
	_dock_order_trees._child_entered_tree(_entered_node)

func _on_tab_cont_child_exiting_tree(_exiting_node: Node) -> void:
	if _is_plugin_actived:
		return
	_debug_system_log("exiting_node", [_exiting_node], "519")

	if _is_close_all:
		_mcontainer_1._dock_item_bar._item_dir_access._clear_type_containers()
		_deselect_sc_list.call_deferred()
		return
	if _is_opened_script:
		return

	if not _is_closed_script:
		_set_is_closed_script(true)
		_dock_order_trees._child_exiting_tree(_exiting_node)

#endregion
################################################################################
#region sig_ closed_script

func _on_script_closed(_sc: Script) -> void:
	if _is_close_all:
		return
	_set_is_file_removed(true)
	_set_is_closed_script(true)
	_handle_closed_script(_sc.resource_path)
	_debug_system_log("close_1", [_sc], "542")


func _handle_closed_script(_path: String) -> void:
	if _path == "":
		return
	_debug_system_log("close_2", [_path], "547")

	var _stemp: Dictionary[int, Dictionary] = _dock_order_trees._get_closed_data(_path)

	match _event_button_num:
		-1, 0, 1: # type_1
			_dock_order_trees._closed_reparent(_path, _stemp)
			_dock_order_trees._timer_closed._set_timer_start_auto(
				0.4, 1, 1, _dock_order_trees._closed_script.bind(_path, "type_1")
				)
		2, 3: # type_2
			_set_is_closed_script(false)

## use_item_add_button
func _closed_container(_num: int) -> void:
	var _cont := _get_focus_mcontainer(_num)
	_cont._te_cedit = null
	_cont._rich_text = null
	_cont._dock_item_bar._item_rich_name._set_init_rich_name()
	__c._saveload_conf._clear_data_index(_num)
	_cont._scte_dict.clear()

#endregion
################################################################################
#region sig_ closed_misc
# Edit Shortcut: script_editor/close_docs

func _on_gui_input_code_edit(_event: InputEvent) -> void:
	if _event is InputEventMouseButton:
		if _event.pressed and _event.button_index == MOUSE_BUTTON_LEFT:
			_set_tooltip_item_bars()

	if _event is InputEventKey:
		## Close
		if _event.is_match(_event_close):
			_event_button_num = 2
			_set_is_close_all(false)
			__notif_event_log("ev_close", [_event_close], "585")

		## Close_All
		elif _event.is_match(_event_close_all):
			_set_is_close_all(true)
			__notif_event_log("ev_close_all", [_event_close_all], "590")

		## Close_other_tabs
		elif _event.is_match(_event_close_other_tabs):
			_event_button_num = 2
			_set_is_close_all(true)
			__notif_event_log("ev_close_other_tabs", [_event_close_other_tabs], "596")

		## Close_docs
		elif _event.is_match(_event_close_docs):
			_event_button_num = 2
			_set_is_close_all(false)
			__notif_event_log("ev_close_docs", [_event_close_docs], "602")


func _on_window_input_sc_head_popup_menu(_event: InputEvent) -> void:
	if _event is InputEventMouseMotion:
		if _event.relative.length() > 0.0:
			if Engine.get_process_frames() % 3 == 0:
				_selected_close(_event, _sc_head_popup_menu)

func _on_window_input_sc_list_popup_menu(_event: InputEvent) -> void:
	if _event is InputEventMouseMotion:
		if _event.relative.length() > 0.0:
			if Engine.get_process_frames() % 3 == 0:
				_selected_close(_event, _plugin._script_list_popup_menu)

func _selected_close(_event: InputEventMouseMotion, _popup_menu: PopupMenu) -> void:
	var _local_pos: Vector2 = _event.position
	var _index: int = _popup_menu.get_focused_item()

	if _index != -1:
		var _item_name: String = _popup_menu.get_item_text(_index)

		match _item_name:
			"Close":
				_event_button_num = 2
				_set_is_close_all(false)

			"Close All":
				_set_is_close_all(true)

			"Close Other Tabs":
				_event_button_num = 2
				_set_is_close_all(true)

			"Close Docs":
				_event_button_num = 2
				_set_is_close_all(false)

func _deselect_sc_list() -> void:
	_plugin._tab_container.deselect_enabled = true
	_plugin._tab_container.current_tab = -1
	_is_tab_changed = false
	_store_tab_index = -1
	_set_is_close_all(false)

#endregion
################################################################################


##:: signal
################################################################################
#region sig_ On_tab_changed

func _on_tab_changed(_tab_index: int) -> void:
	if _is_closed_script or _is_file_removed:
		return
	if _event_button_num == 2 or _is_opened_script:
		return
	if _is_open_doc:
		return
	_store_tab_index = _tab_index

	if not _plugin._initial_load:
		_caret_changed_position()
		_handler_get_sc_stat(_store_focus_index)

	if not _is_tab_changed:
		_handler_swap_script(_store_focus_index, _store_tab_index)
	_set_scroll_past_end()

	if code_edit != null:
		__c._find_word_script_tools._get_words_from_script(code_edit)
	__notif_log("on_tab_changed", [_tab_index], "674")

#endregion
################################################################################
#region sig_ On_connect

func _on_caret_changed() -> void:
	_caret_changed_position()

func _on_line_edit_text_changed(_new_text: String) -> void:
	__c._find_word_script_tools._find_on_text_changed(code_edit, _new_text)
	_event_dock_input._store_click_word = _new_text
	#print("on_line_edit_text_changed: ", _new_text)

func _on_distract_button_pressed(toggle: bool) -> void:
	_is_distract_button = toggle
	_timer_distruct_button._set_timer_start_auto(
		0.1, 1, 1, _on_timeout_distruct_pressed.bind(_is_distract_button)
		)
	__c._item_exp_setter._set_defualt_unfocus_expand()
	__c._item_exp_setter._set_focus_expand_selected([1, 1, 1])

func _on_visibility_changed_ehelp() -> void:
	if _plugin._editor_help_search.visible:
		_plugin._get_help_tree("set")
		_doc_helper._check_signal_ehelp("connect")
	else:
		_doc_helper._check_signal_ehelp("disconnect")
		_plugin._get_help_tree("null")

func _on_go_to_help(_what: String) -> void:
	_doc_helper._what_go_to_help(_what)

#endregion
###############################################################################
#region sig_ is_connect

func _check_is_connected(_type: String) -> void:
	if code_edit != null:
		match _type:
			"disconnect":
				if code_edit.is_connected("gui_input", _event_dock_input._on_gui_input):
					code_edit.disconnect("gui_input", _event_dock_input._on_gui_input)
					code_edit.disconnect("gui_input", _on_gui_input_code_edit)
				if code_edit.is_connected("caret_changed", _on_caret_changed):
					code_edit.disconnect("caret_changed", _on_caret_changed)

				if _script_ebase != null:
					if _script_ebase.is_connected("go_to_help", _on_go_to_help):
						_script_ebase.disconnect("go_to_help", _on_go_to_help)

			"connect":
				if not code_edit.is_connected("gui_input", _event_dock_input._on_gui_input):
					__c._setup_signal.connect_gui_input(code_edit, _event_dock_input._on_gui_input)
					__c._setup_signal.connect_gui_input(code_edit, _on_gui_input_code_edit)

				if not code_edit.is_connected("caret_changed", _on_caret_changed):
					__c._setup_signal.connect_caret_changed(code_edit, _on_caret_changed)

				if _script_ebase != null:
					if not _script_ebase.is_connected("go_to_help", _on_go_to_help):
						__c._setup_signal.connect_goto_help(_script_ebase, _on_go_to_help)

#endregion
################################################################################


##:: _key_inputs
################################################################################
#region _gui On_gui_input

func _on_gui_input_item_list(_event: InputEvent) -> void:
	if _event is InputEventMouseButton:
		if _event.pressed and _event.button_index == MOUSE_BUTTON_LEFT or \
			_event.pressed and _event.button_index == MOUSE_BUTTON_MIDDLE or \
			_event.pressed and _event.button_index == MOUSE_BUTTON_RIGHT:
			_event_button_num = _event.button_index
			_set_is_close_all(false)

	if _event is InputEventMouseMotion:
		if _event.relative.length() > 0.0:
			if Engine.get_process_frames() % 3 == 0:
				var _local_pos: Vector2 = _event.position
				var _index: int = _script_item_list.get_item_at_position(_local_pos, true)
				if _index != -1:
					var _item_name: String = _script_item_list.get_item_text(_index)

					if _store_name_hover_item == _item_name:
						return
					else:
						_store_name_hover_item = ""
					_store_name_hover_item = _item_name
					_utility_panel_frash(_item_name)

func _utility_panel_frash(_item_name: String) -> void:
	for dict: Dictionary in _get_scte_arr():
		var _name: Array = dict.get("sc_name", [])
		var _ce: CodeEdit = dict.get("code_edit", null)

		if _name.is_empty() or _ce == null:
			continue

		for child in _ce.get_children():
			if child is Panel:
				return

		if _item_name == _name[1]:
			var _ftype: int = __c._setup_project._get_focus_flash_type()
			await __c._setup_settings._set_theme_override_panel_focus(_ce, _ftype, "panel")
			break

#endregion
################################################################################
#region _gui fevent_unhandle

func _unhandled_key_input(_event: InputEvent) -> void:
	if _event is InputEventKey and _event.pressed:
		var _inputkeys: Dictionary = __c._setup_project._inputkey_dict

		if _event.is_match(_inputkeys["Focus_1"]):
			for child in _mcontainer_1._vbox.get_children():
				if child is VSplitContainer:
					if _mcontainer_1._code_edit == null:
						_mcontainer_1._code_edit = _mcontainer_1._get_vbox_child_ce()
					if _mcontainer_1._code_edit != null:
						__c._item_exp_setter._focus_selected(1, [1, 0, 0])
						return
				if child.is_class(&"CodeEdit"):
					if _mcontainer_1._te_cedit != null:
						_mcontainer_1._rich_text = null
						__c._item_exp_setter._focus_selected(1, [1, 0, 0])
						return
				if child is RichTextLabel:
					if _mcontainer_1._rich_text != null:
						_mcontainer_1._te_cedit = null
						__c._item_exp_setter._focus_selected(1, [1, 0, 0])
						return

		elif _event.is_match(_inputkeys["Focus_2"]):
			for child in _mcontainer_2._vbox.get_children():
				if child is VSplitContainer:
					if _mcontainer_2._code_edit == null:
						_mcontainer_2._code_edit = _mcontainer_2._get_vbox_child_ce()
					if _mcontainer_2._code_edit != null:
						__c._item_exp_setter._focus_selected(2, [0, 1, 0])
						return
				if child.is_class(&"CodeEdit"):
					if _mcontainer_2._te_cedit != null:
						_mcontainer_2._rich_text = null
						__c._item_exp_setter._focus_selected(2, [0, 1, 0])
						return
				if child is RichTextLabel:
					if _mcontainer_2._rich_text != null:
						_mcontainer_2._te_cedit = null
						__c._item_exp_setter._focus_selected(2, [0, 1, 0])
						return

		elif _event.is_match(_inputkeys["Focus_3"]):
			for child in _mcontainer_3._vbox.get_children():
				if child is VSplitContainer:
					if _mcontainer_3._code_edit == null:
						_mcontainer_3._code_edit = _mcontainer_3._get_vbox_child_ce()
					if _mcontainer_3._code_edit != null:
						__c._item_exp_setter._focus_selected(3, [0, 0, 1])
						return
				if child.is_class(&"CodeEdit"):
					if _mcontainer_3._te_cedit != null:
						_mcontainer_3._rich_text = null
						__c._item_exp_setter._focus_selected(3, [0, 0, 1])
						return
				if child is RichTextLabel:
					if _mcontainer_3._rich_text != null:
						_mcontainer_3._te_cedit = null
						__c._item_exp_setter._focus_selected(3, [0, 0, 1])
						return

#endregion
################################################################################


##:: get_containers
################################################################################
#region cont_focus_options

func _get_mcontainer_arr() -> Array[SMPDockContainer]:
	return [_mcontainer_1, _mcontainer_2, _mcontainer_3]

func _get_scte_arr() -> Array[Dictionary]:
	return [
		_mcontainer_1._get_scte_dict(),
		_mcontainer_2._get_scte_dict(),
		_mcontainer_3._get_scte_dict(),
		]

func _get_focus_mcontainer(_f_index: int) -> SMPDockContainer:
	match _f_index:
		1:
			return _mcontainer_1
		2:
			return _mcontainer_2
		3:
			return _mcontainer_3
	return null

func _get_focus_scte_dict(_f_index: int) -> Dictionary:
	match _f_index:
		1:
			return _mcontainer_1._get_scte_dict()
		2:
			return _mcontainer_2._get_scte_dict()
		3:
			return _mcontainer_3._get_scte_dict()
	return {}

#endregion
################################################################################
#region cont_handle

func _handler_get_sc_stat(_findex: int) -> void:
	match _findex:
		1:
			_mcontainer_1._get_script_status()
		2:
			_mcontainer_2._get_script_status()
		3:
			_mcontainer_3._get_script_status()

func _handler_swap_script(_findex: int, _tindex: int) -> void:
	match _findex:
		1:
			_mcontainer_1._handler_changed_container(_tindex)
		2:
			_mcontainer_2._handler_changed_container(_tindex)
		3:
			_mcontainer_3._handler_changed_container(_tindex)

#endregion
################################################################################


##:: debug
################################################################################
#region __notif

func _debug_system_log(_log: String, _vari: Array, _line: String) -> void:
	if _debug_manager._node_order_tree:
		_debug_manager._log_signal("pri", self, _log, _vari, _line)

func __notif_log(_log: String, _vari: Array, _line: String) -> void:
	if _debug_manager._tab_changed:
		_debug_manager._log_signal("pri", self, _log, _vari, _line)

func __notif_event_log(_log: String, _vari: Array, _line: String) -> void:
	if _debug_manager._event_log:
		_debug_manager._log_signal("pri", self, _log, _vari, _line)

#endregion


