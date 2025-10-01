@tool
class_name ScriptMultiPlusPlugin
extends EditorPlugin


var SMP_DOCKMAIN: Resource = load("uid://qhoglio2h01n")

var _dock_main: ScriptMultiPlusDock
var _dock_name: String = "ScriptMultiPlus"

""" setup_class """
var __c: SMPClassManagers
var _debug_manager: SMPDebugManager

""" file_trees """
var _tree_file_dock: Tree
var _filesystem_dock: FileSystemDock

""" tab_container """
var _tab_container: TabContainer
var _tab_container_parent: VBoxContainer
var _tab_container_root: Variant

""" find """
var _find_buttons: Array[Button]
var _find_replace_line_edit: LineEdit
var _find_replace_bar: Node

""" script_editor """
var _script_editor: ScriptEditor
var _script_editor_menu_container: HBoxContainer
var _script_list_container: VSplitContainer
var _list_top: VBoxContainer

""" script_menus """
var _script_item_list: ItemList
var _script_menu_button: MenuButton
var _script_list_popup_menu: PopupMenu

""" editor_help_search """
var _editor_help_search: Node
var _ehelp_vbox: VBoxContainer
var _ehelp_tree: Tree
var _ehelp_open_button: Button
var _ehelp_line_edit: LineEdit

""" editor_buttons """
var _editor_distract_button: Button
var _script_editor_window: Window
var _screen_select: Button

""" bools """
var _is_once_call: bool = true
var _initial_load: bool = true
var _is_plugin_enable: bool = false

var _time: float = 0


##:: setup_lazy
################################################################################
#region _setup_lazy

func _get_class_all(_setup_class: SMPClassManagers) -> SMPClassManagers:
	if _setup_class == null:
		_setup_class = SMPClassManagers.new()
	return _setup_class

func _set_init_classes() -> void:
	__c = _get_class_all(__c)
	__c._plugin = self
	__c._setup_init_lazy()
	__c._setup_arr.push_back(self)

func _is_disable_screen_select(_active: bool) -> void:
	_screen_select.disabled = _active

#endregion
################################################################################


##:: tree
################################################################################
#region tree_enter_exit

func _enter_tree() -> void:
	_set_init_classes()
	_get_node_parts()
	__c._setup_settings._set_container_flag(_tab_container, "fill")
	_add_dock_main()

func _exit_tree() -> void:
	if is_instance_valid(_dock_main):
		_exit_disconn_signal()
		_exit_container_position()
		__c._setup_settings._set_container_flag(_tab_container, "exp")
		_set_visible_tab_cont(true)
		_is_disable_screen_select(false)
		_dock_main.queue_free()

func _process(_delta: float) -> void:
	_time += _delta
	if _time > 2.0:
		set_process(false)
		_enabled_layout_tpost()
		_dock_main._set_signal_lazy()
		__c._saveload_conf._loading_data_lazy()
		await get_tree().process_frame
		_check_is_conneted("disconnect")
		_boot_layout.call_deferred("apost")
		_is_once_call = false
		__boot_loaded_data_log("91")
		#print("process_stop")

#endregion
################################################################################


##:: dock
################################################################################
#region _dock_add_remove

func _add_dock_main() -> void:
	var _scene := SMP_DOCKMAIN
	if _scene:
		_dock_main = _scene.instantiate()
		_setup_dock_main()
		_enter_container_position()
		_set_ready_setup()
		_check_is_conneted("connect")
		__c._saveload_conf._loading_data()
	else:
		push_error("[ScriptMultiPlusPlugin]: PackedScene failed to load")

#endregion
################################################################################
#region set_ready_classes

func _setup_dock_main() -> void:
	_dock_main.set_name(_dock_name)
	_dock_main._setup_class(__c._setup_arr)
	__c._saveload_conf._setup_class(__c._setup_arr)

func _enter_container_position() -> void:
	_tab_container_parent.add_child(_dock_main)
	_dock_main.get_parent().move_child(_dock_main, 0)
	__c._setup_arr.push_back(_dock_main)

func _set_ready_setup() -> void:
	_set_debug_manager()
	_dock_main._find_popup_panel._set_init_popup_panel()
	_dock_main._find_popup_panel._setup_class(__c._setup_arr)

	_dock_main._setup_mcontainer_class(__c._setup_arr)
	_dock_main._mcontainer_1._dock_item_bar._set_class(__c._setup_arr)
	_dock_main._mcontainer_2._dock_item_bar._set_class(__c._setup_arr)
	_dock_main._mcontainer_3._dock_item_bar._set_class(__c._setup_arr)
	_dock_main._dock_order_trees._setup_class(__c._setup_arr)

	__c._saveload_conf._setup_class(__c._setup_arr)
	__c._saveload_handler._setup_class(__c._setup_arr)
	__c._saveload_filesystem._setup_class(__c._setup_arr)

	__c._find_word_script_tools._setup_class(__c._setup_arr)
	__c._find_word_tools._setup_class(__c._setup_arr)

	__c._split_utility._setup_class(__c._setup_arr)
	__c._event_dock_input._setup_class(__c._setup_arr)
	__c._scroll_caret_calc._setup_class(__c._setup_arr)
	__c._item_exp_setter._setup_class(__c._setup_arr)
	__c._doc_helper._setup_class(__c._setup_arr)

func _check_is_conneted(_type: String) -> void:
	match _type:
		"disconnect":
			if __c._setup_project._settings.is_connected("settings_changed", _on_settings_changed):
				__c._setup_project._settings.disconnect("settings_changed", _on_settings_changed)
		"connect":
			if not __c._setup_project._settings.is_connected("settings_changed", _on_settings_changed):
				__c._setup_signal.connect_settings_changed(__c._setup_project._settings, _on_settings_changed)

func _set_debug_manager() -> void:
	_debug_manager = _dock_main._debug_manager
	__c._setup_arr.push_back(_debug_manager)

#endregion
################################################################################


##:: set_get_exit
################################################################################
#region set_find_button_status

func _set_focus_directions() -> void:
	var _button_up: Button = _find_buttons[0]
	var _button_down: Button = _find_buttons[1]

	_find_replace_line_edit.focus_next = _button_up.get_path()
	_button_up.focus_next = _button_down.get_path()
	_button_down.focus_previous = _button_up.get_path()

	_button_up.focus_mode = Control.FOCUS_ALL
	_button_down.focus_mode = Control.FOCUS_ALL

#endregion
################################################################################
#region set_exit_container_position

func _exit_disconn_signal() -> void:
	if _dock_main.code_edit != null:
		if _dock_main.code_edit.is_connected("gui_input", _dock_main._event_dock_input._on_gui_input):
			_dock_main.code_edit.disconnect("gui_input", _dock_main._event_dock_input._on_gui_input)
			_dock_main._plugin._script_editor.disconnect("script_close", _dock_main._on_script_closed)

func _exit_container_position() -> void:
	__exit_data_debug_log(_dock_main._get_scte_arr(), "182")
	var _tchildren: Array[Node] = _tab_container.get_children()

	for scte: Dictionary in _dock_main._get_scte_arr():
		for container: SMPDockContainer in _dock_main._get_mcontainer_arr():
			if container._vbox.get_child_count() > 0:
				var _hbox := container._get_code_edit_hbox()
				if _hbox != null:
					_hbox.set_visible(true)

				for vchild in container._vbox.get_children():
					if vchild is VSplitContainer:
						for tchild in _tchildren:
							_container_position(tchild, vchild, scte)
					elif vchild is RichTextLabel:
						for tchild in _tchildren:
							_container_position_doc(tchild, vchild, scte, "root")
					elif vchild is CodeEdit:
						for tchild in _tchildren:
							_container_position_doc(tchild, vchild, scte, "parent")

func _container_position(_tchild: Node, _vchild: Node, _dict: Dictionary) -> void:
	var _scte: Node = _dict.get("root", null)
	var _ce: CodeEdit = _dict.get("code_edit", null)
	if _scte == null:
		return
	if _tchild.name == _scte.name:
		_vchild.reparent(_tchild)
		_vchild.get_parent().move_child(_vchild, 0)
		if _ce != null:
			_ce.remove_theme_stylebox_override("focus")
		__c._setup_settings._set_container_flag(_tab_container, "exp")
		_dict.clear()

func _container_position_doc(_tchild: Node, _vchild: Node, _dict: Dictionary, _type: String) -> void:
	var _select: Node
	var _root: Node = _dict.get("root", null)
	var _parent: Node = _dict.get("parent", null)
	var _findbar: Node = _dict.get("findbar", null)

	if _root == null:
		return
	match _type:
		"root":
			_select = _root
		"parent":
			_select = _parent

	if _tchild.name == _root.name:
		if _findbar != null:
			_findbar.reparent(_select)
			_findbar.get_parent().move_child(_findbar, 0)
		_vchild.reparent(_select)
		_vchild.get_parent().move_child(_vchild, 0)
		_vchild.remove_theme_stylebox_override("focus")
		__c._setup_settings._set_container_flag(_tab_container, "exp")
		_dict.clear()

## diraccess
func _clear_data_container_state(_type: String) -> void:
	await get_tree().process_frame
	var _mcont1 := _dock_main._get_focus_mcontainer(1)
	var _mcont2 := _dock_main._get_focus_mcontainer(2)
	var _mcont3 := _dock_main._get_focus_mcontainer(3)
	if _mcont1._vbox.get_child_count() == 0:
		_mcont1._get_add_button().set_visible(false)
		match _type:
			"pre":
				_mcont1._get_add_button()._container_state_1(false)
				_mcont2._get_add_button()._set_add_handle(2, false)
				_mcont3._get_add_button()._set_add_handle(3, false)
				_mcont2._get_recent_menu_item()._saving_menu_index(-1)
				_mcont3._get_recent_menu_item()._saving_menu_index(-1)
			"post":
				if _mcont1._get_add_button_state():
					_mcont1._get_add_button()._is_add_button = false
				_mcont1._notepad_container._code_notepad.focus_entered.emit.call_deferred()
				await get_tree().process_frame
				_mcont1._set_notepad_grab_focus()
				_mcont1._get_add_button()._set_init_icon(1)

#endregion
################################################################################
#region get_node, get_code_edit

var _selection: EditorSelection

func _get_node_parts() -> void:
	_filesystem_dock = EditorInterface.get_file_system_dock()
	_tree_file_dock = __c._setup_utility._find_node_tree(_filesystem_dock)

	""" script """
	_script_editor = __c._setup_utility._get_script_editor()
	_script_menu_button = __c._setup_utility._find_editor_container(_script_editor, &"MenuButton")
	_script_list_container = __c._setup_utility._find_editor_container_avoid(_script_editor, &"VSplitContainer")
	_script_editor_menu_container = __c._setup_utility._find_editor_container(_script_editor, &"HBoxContainer")
	_script_item_list = __c._setup_utility._get_script_item_list()
	_script_list_popup_menu = __c._setup_utility._find_get_children(_script_editor, &"PopupMenu")

	""" tab_container """
	_tab_container = __c._setup_utility._find_editor_container(_script_editor, &"TabContainer")
	_tab_container_parent = _tab_container.get_parent()
	_tab_container_root = _tab_container_parent.get_parent()

	""" find_box """
	_find_replace_bar = __c._setup_utility._find_replace_line_edit(_tab_container_parent, &"FindReplaceBar")
	_find_replace_line_edit = __c._setup_utility._find_replace_line_edit(_tab_container_parent, &"LineEdit")
	_find_buttons = __c._setup_utility._find_get_button_up(_find_replace_line_edit)

	""" misc """
	_list_top = _script_list_container.get_child(0)
	_editor_distract_button = __c._setup_utility._get_distraction_button()
	_script_editor_window = __c._setup_utility._find_get_children(_script_editor.get_parent(), &"Window")
	_screen_select = __c._setup_utility._find_get_children(_script_editor_menu_container, &"ScreenSelect")

	""" editor_help_searchs """
	_editor_help_search = __c._setup_utility._find_get_children(_script_editor, &"EditorHelpSearch")
	_ehelp_vbox = __c._setup_utility._find_get_children(_editor_help_search, &"VBoxContainer")
	_ehelp_line_edit = __c._setup_utility._find_editor_container(_ehelp_vbox, &"LineEdit")
	_ehelp_tree = __c._setup_utility._find_editor_container(_ehelp_vbox, &"Tree")
	_ehelp_open_button = _editor_help_search.get_ok_button() # 12969

	_set_focus_directions()
	_is_disable_screen_select(true)

	__c._setup_arr.push_back(_tree_file_dock)
	__c._setup_arr.push_back(_script_item_list)
	__c._setup_arr.push_back(_find_replace_bar)
	__c._setup_arr.push_back(_find_replace_line_edit)
	__c._setup_arr.push_back(_editor_help_search)

	__check_node_order(0)

func _get_help_tree(_type: String) -> void:
	match _type:
		"set":
			if _ehelp_tree == null:
				_ehelp_tree = __c._setup_utility._find_editor_container(_ehelp_vbox, &"Tree")
		"null":
			_ehelp_tree = null

#endregion
################################################################################
#region get_code_edit_table

func _get_parent_code_edit_container(_code_edit: CodeEdit) -> Dictionary:
	var _index: int = 0
	var _root := __c._setup_utility._find_code_edit_parent(_code_edit, &"ScriptTextEditor")
	var _container := __c._setup_utility._find_code_edit_parent(_code_edit, &"VSplitContainer")

	if _root == null or _container == null:
		push_warning("Not find> root: %s, container: %s" % [_root, _container])
		push_warning("Not find container: %s" % _code_edit)
		return {}

	for child in _tab_container.get_children():
		if child.name == _root.name:
			break
		_index += 1

	## name: _script_item_list.get_item_text(_index)
	var _names: Array[String] = _dock_main._get_script_name(_index)

	var _dict: Dictionary = _data_table(
		1, _index, _root, _container, _code_edit, _names,
		)
	return _dict

func _data_table(
	_focus_index: int, _tindex: int, _root: Node, _container: Container,
	_code_edit: CodeEdit, _name: Array[String],
	_sc_path: String = "", _suid_path: String = "",
	) -> Dictionary:
	var _dict: Dictionary = {
		"focus_index": _focus_index,
		"tab_index"   : _tindex,
		"root"        : _root,
		"parent"      : _container,
		"code_edit"   : _code_edit,
		"sc_name"     : _name,
		"script_path" : _sc_path,
		"uid_path"    : _suid_path,
	}
	return _dict

func _data_table_doc(
	_focus_index: int, _tindex: int, _root: Node, _parent: Node,
	_rich_text: Node, _findbar: Node, _cedit: CodeEdit,	_name: Array[String],
	) -> Dictionary:
	var _dict: Dictionary = {
		"focus_index" : _focus_index,
		"tab_index"   : _tindex,
		"root"        : _root,
		"parent"      : _parent,
		"rich_text"   : _rich_text,
		"findbar"   : _findbar,
		"cedit"       : _cedit,
		"sc_name"     : _name,
	}
	return _dict

#endregion
################################################################################


##:: boot
################################################################################
#region sig On_connect

#func _set_window_layout(_conf: ConfigFile) -> void:
	#print("set_window_layout")

func _enable_plugin() -> void:
	_is_plugin_enable = true
	_debug_manager._log_signal("pri", self, "enable_plugin", "", "381")
	__c._setup_settings._set_container_flag(_tab_container, "fill")
	__c._setup_settings._set_container_flag(_dock_main._mcontainer_1._vbox, "fill")
	_dock_main._find_popup_panel._set_init_popup_panel()
	_set_visible_tab_cont(false)
	_enabled_layout_pre()

func _get_window_layout(_conf: ConfigFile) -> void:
	if _initial_load:
		_set_visible_tab_cont(false)
		_dock_main._update_container_list()
		_loading_rebuild_recent_data_index("both")
		__c._saveload_filesystem._load_select_tab_changed()
		__c._saveload_filesystem._load_move_new_parent()
		__c._setup_settings._set_container_flag.call_deferred(_tab_container, "fill")
		__c._saveload_conf._loading_data_lazy()
		_loading_recent_menu_set()
		_boot_layout("post")
		set_process(true)
	_initial_load = false
	_debug_manager._log_signal("pri", self, "get_window_layout", "", "401")

func _on_settings_changed() -> void:
	if _initial_load:
		_dock_main._find_popup_panel._set_init_popup_panel()
		if not __c._godot_conf.has_section(__c._setup_settings._section):
			_initial_load = false
		else:
			_boot_layout("pre")
			_enabled_dock_split_offset()
			if _is_plugin_enable:
				_loading_rebuild_recent_data_index("both")
				__c._saveload_filesystem._load_enable_pressed()
				__c._saveload_filesystem._load_move_new_parent()
				__c._saveload_conf._loading_data_lazy()
				_dock_main._set_boot_empty()
				_enabled_layout_post()
				_loading_recent_menu_set()
				_boot_layout("post")
				set_process(true)
				_initial_load = false
	_debug_manager._log_signal("pri", self, "on_settings_changed", "", "422")

#endregion
################################################################################
#region boot_layout_helper

func _set_visible_tab_cont(_active: bool) -> void:
	_tab_container.set_visible(_active)

func _boot_layout(_type: String) -> void:
	var _containers := _dock_main._get_mcontainer_arr()
	var _mcont1 := _containers[0]
	var _mcont2 := _containers[1]
	var _mcont3 := _containers[2]
	_dock_main._dock_split2.set_visible(false)

	match _type:
		"pre":
			for cont: SMPDockContainer in _containers:
				_dock_main._dock_split2.set_visible(false)
				cont._dock_item_bar.set_visible(false)
		"post":
			for cont: SMPDockContainer in _containers:
				cont._dock_item_bar.set_visible(true)
		"apost":
			if _mcont2._vbox.get_child_count() > 0 or \
				_mcont3._vbox.get_child_count() > 0:
				_dock_main._dock_split2.set_visible(true)
			if _mcont3._vbox.get_child_count() > 0:
				_mcont1._dock_item_bar._item_add_button.set_visible(false)

			for cont: SMPDockContainer in _containers:
				cont._get_recent_menu_item()._set_protect_data(-1)
				cont._get_recent_menu_item()._exs_check_sc_list()
				if _dock_main._is_unloaded_data:
					cont._set_visible_ordering_child_load_initial()
			_dock_main._is_unloaded_data = false

func _enabled_dock_split_offset() -> void:
	var _data: Array = __c._saveload_conf._lazy_loading_data()
	if not _data.is_empty():
		__c._split_utility._loading_container_data.call_deferred(_data[0], _data[1])

func _enabled_layout_pre() -> void:
	var _containers := _dock_main._get_mcontainer_arr()
	for cont: SMPDockContainer in _containers:
		cont.set_visible(false)
		cont._dock_item_bar.set_visible(false)
	_containers[1].set_visible(true)
	_containers[0]._set_visible_notepad(false)

func _enabled_layout_post() -> void:
	var _containers := _dock_main._get_mcontainer_arr()
	for cont: SMPDockContainer in _containers:
		if cont._vbox.get_child_count() > 0:
			cont.set_visible(true)
			__c._setup_settings._set_container_flag.call_deferred(cont._vbox, "exp")
		cont._dock_item_bar._item_hbox.set_visible(false)

	if _containers[1]._vbox.get_child_count() > 0:
		_dock_main._dock_split2.set_visible(true)
	else:
		_dock_main._dock_split2.set_visible(false)

func _enabled_layout_tpost() -> void:
	var _containers := _dock_main._get_mcontainer_arr()
	for cont: SMPDockContainer in _containers:
		cont._dock_item_bar._item_hbox.set_visible(true)
		cont._dock_item_bar._item_add_button._process_button_state()

#endregion
################################################################################
#region boot_recent_loading

func _loading_recent_menu_set() -> void:
	if _initial_load:
		var _recent_menu_1: SMPRecentMenuButton = _dock_main._mcontainer_1._dock_item_bar._item_recent_menu
		var _recent_menu_2: SMPRecentMenuButton = _dock_main._mcontainer_2._dock_item_bar._item_recent_menu
		var _recent_menu_3: SMPRecentMenuButton = _dock_main._mcontainer_3._dock_item_bar._item_recent_menu
		_recent_menu_1._loading_recent_data()
		_recent_menu_2._loading_recent_data()
		_recent_menu_3._loading_recent_data()

func _loading_rebuild_recent_data_index(_type: String) -> void:
	var _containers := _dock_main._get_mcontainer_arr()
	for cont: SMPDockContainer in _containers:
		match _type:
			"cont":
				__c._saveload_filesystem._update_boot_rebuild_container_data(cont.container_index)
			"recent":
				__c._saveload_filesystem._update_boot_rebuild_recent_data(cont.container_index)
			"both":
				__c._saveload_filesystem._update_boot_rebuild_container_data(cont.container_index)
				__c._saveload_filesystem._update_boot_rebuild_recent_data(cont.container_index)

#endregion
################################################################################


##:: debug
################################################################################
#region _debug_

func __boot_loaded_data_log(_line: String) -> void:
	if not _debug_manager._load_enabled:
		return
	for dict: Dictionary in _dock_main._get_scte_arr():
		var _notif: Array = _debug_manager._data_dict_arr_notif(dict)
		_debug_manager._debug_log("rich", self, "loaded_data", _notif, _line)

func __exit_data_debug_log(_data_arr: Array, _line: String) -> void:
	if not _debug_manager._exit_tree_data:
		return
	for dict: Dictionary in _data_arr:
		var _notif: Array = _debug_manager._data_dict_arr_notif(dict)
		_debug_manager._log_signal("rich", self, "exit_tree_data", _notif, _line)


func __check_node_order(_active: int = 0) -> void:
	if _active != 0:
		var _node_arr: Array = [
			_script_editor,
			_script_menu_button,
			_script_list_container,
			_script_editor_menu_container,
			_script_item_list,
			_script_list_popup_menu,

			_tab_container, _tab_container_parent, _tab_container_root,

			_find_replace_bar, _find_replace_line_edit, _find_buttons,

			_list_top,
			_editor_distract_button,
			_script_editor_window,
			_screen_select,

			_editor_help_search,
			_ehelp_vbox,
			_ehelp_tree,
			_ehelp_open_button,

		]

		for node in _node_arr:
			print("check_node: ", node)

#endregion
################################################################################

