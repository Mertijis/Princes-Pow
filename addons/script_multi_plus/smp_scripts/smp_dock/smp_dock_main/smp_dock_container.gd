@tool
class_name SMPDockContainer
extends MarginContainer


@export var container_index: int

""" class """
var __c: SMPClassManagers
var _debug_manager: SMPDebugManager
var _plugin: ScriptMultiPlusPlugin
var _dock_main: ScriptMultiPlusDock

var _timer_document: SMPTimerUtility

""" containers """
var _container1: SMPDockContainer
var _container2: SMPDockContainer
var _container3: SMPDockContainer

""" type_script """
var _code_edit: CodeEdit:
	set(_value):
		_code_edit = _value
	get:
		return _code_edit

""" type_document """
var _rich_text: RichTextLabel:
	set(_value):
		_rich_text = _value
	get:
		return _rich_text

""" type_text_editor """
var _te_cedit: CodeEdit:
	set(_value):
		_te_cedit = _value
	get:
		return _te_cedit

""" store_data """
var _store_tab_index: int
var _store_sc_names: Array[String]
var _store_script_path: String
var _store_script_path_uid: String
var _store_title: String

var _scte_dict: Dictionary
var _script_item_list: ItemList


var _is_editor_misc: bool = false

@onready var _vbox: SMPDockVbox = %DockVBox
@onready var _dock_item_bar: SMPDockItemBar = %DockItemBar
@onready var _notepad_container: SMPDockNotePad = %NotepadContainer


##:: setup
################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is ScriptMultiPlusPlugin:
				_plugin = item
			elif item is ScriptMultiPlusDock:
				_dock_main = item
			elif item is SMPDebugManager:
				_debug_manager = item
			elif item is ItemList:
				_script_item_list = item
			elif item is SMPClassManagers:
				__c = item

	_timer_document = SMPTimerUtility.new(_dock_main)

	_vbox._setup_class(__c._setup_arr)
	_notepad_container._setup_class(__c._setup_arr)
	__c._setup_settings._set_container_flag(_vbox, "fill")

	_set_ready_signal()
	_set_container()

func _set_container() -> void:
	_container1 = _dock_main._get_focus_mcontainer(1)
	_container2 = _dock_main._get_focus_mcontainer(2)
	_container3 = _dock_main._get_focus_mcontainer(3)

#endregion
################################################################################
#region set_status

func _set_ready_signal() -> void:
	__c._setup_signal.connect_child_order_changed(_vbox, _on_child_order_changed)
	__c._setup_signal.connect_child_entered_tree(_vbox, _on_child_entered_tree)
	__c._setup_signal.connect_child_exiting_tree(_vbox, _on_child_exiting_tree)

func _set_notepad_grab_focus() -> void:
	_notepad_container._code_notepad.grab_focus.call_deferred()

func _set_visible_notepad(_active: bool) -> void:
	_notepad_container.set_visible(_active)

func _get_scte_dict() -> Dictionary:
	return _scte_dict

func _get_vbox_children() -> Array[Node]:
	return _vbox.get_children()

func _get_script_status() -> void:
	if _code_edit != null:
		_store_script_path = _dock_main._get_script_path()
		_store_script_path_uid = _dock_main._get_script_path_uid()

func _get_code_edit_hbox() -> HBoxContainer:
	if _code_edit != null:
		var _scte: Node = _code_edit.get_parent()
		for child in _scte.get_children():
			if child is HBoxContainer:
				return child
	return null

func _get_ce_hbox(_ce: CodeEdit) -> HBoxContainer:
	if _ce != null:
		var _scte: Node = _ce.get_parent()
		for child in _scte.get_children():
			if child is HBoxContainer:
				return child
	return null

func _get_vbox_child_ce() -> CodeEdit:
	var _children: Array[Node] = _vbox.get_children()
	for child in _children:
		if child is VSplitContainer:
			return __c._setup_utility._find_node(child, "CodeEdit")
	return null

func _get_vbox_child_rich_text() -> RichTextLabel:
	var _children: Array[Node] = _vbox.get_children()
	for child in _children:
		if child is RichTextLabel:
			return child
	return null

func _get_vbox_child_findbar() -> Node:
	var _children: Array[Node] = _vbox.get_children()
	for child in _children:
		if child.is_class(&"FindBar"):
			return child
	return null

#endregion
################################################################################
#region setget_items

func emit_expand_button_pressed() -> void:
	_dock_item_bar._item_expand_button.pressed.emit()

func _set_expand_button(_active: bool) -> void:
	_dock_item_bar._item_expand_button._is_expand_button = _active

func _set_expand_button_tooltip(_tooltip: String) -> void:
	_dock_item_bar._item_expand_button.tooltip_text = _tooltip

func _set_rich_text_item(_text: Array[String]) -> void:
	_dock_item_bar._item_rich_name._set_rich_label_name(_text)

func _set_recent_menu_tooltip(_tooltip: String) -> void:
	_dock_item_bar._item_recent_menu.tooltip_text = _tooltip

""" get_item """
func _get_expand_button_state() -> bool:
	return _dock_item_bar._item_expand_button.get_button_state()

func _get_vert_button_state() -> bool:
	return _dock_item_bar._item_vertical_button._get_button_state()

func _get_add_button() -> SMPItemAddButton:
	return _dock_item_bar._item_add_button

func _get_add_button_state() -> bool:
	return _dock_item_bar._item_add_button._get_button_state()

func _get_recent_menu_item() -> SMPRecentMenuButton:
	return _dock_item_bar._item_recent_menu

func _get_dir_button() -> SMPItemDirAcess:
	return _dock_item_bar._item_dir_access

func _get_dir_button_state() -> bool:
	return _dock_item_bar._item_dir_access._get_button_state()

#endregion
################################################################################


##:: change_process
################################################################################
#region exist_check_loaded_script

func _check_is_loaded_script(_tindex: int) -> bool:
	var _names: Array[String] = _dock_main._get_script_name(_tindex)
	if not _names.is_empty():
		for dict: Dictionary in _dock_main._get_scte_arr():
			var _sc_names: Array = dict.get("sc_name", [])

			if not _sc_names.is_empty():
				if _names[1] == _sc_names[1]:
					_check_focus_loaded_script(dict)

					if _dock_main._is_distract_button:
						__c._split_utility._change_dock_split_vert_button_D()
					else:
						__c._item_exp_setter._change_expand_split_offset("ret", "", [1, 0, 0])
						__c._item_exp_setter._set_defualt_unfocus_expand()
						__c._item_exp_setter._set_focus_expand_selected([1, 1, 1])
					return true
	return false

func _check_focus_loaded_script(_dict: Dictionary) -> void:
	var _sc_names: Array = _dict.get("sc_name", [])
	var _findex: int = _dict.get("focus_index", -1)
	var _vsplit := _dict.get("parent")
	var _mcont := _dock_main._get_focus_mcontainer(_findex)
	_mcont._check_is_connected(_vsplit, "connect")
	_dock_main._store_focus_index = _findex
	if _mcont._code_edit != null:
		_mcont._code_edit.grab_focus.call_deferred()

#endregion
################################################################################
#region change_pre

func _change_to_return_container() -> void:
	if _scte_dict.is_empty():
		return

	var _root := _scte_dict.get("root", null)
	var _parent := _scte_dict.get("parent", null)
	var _ce := _scte_dict.get("code_edit", null)

	var _findbar := _scte_dict.get("findbar", null)
	var _rtext := _scte_dict.get("rich_text", null)
	var _cedit := _scte_dict.get("cedit", null)

	if _cedit != null:
		_change_reparent(_cedit, _parent)
		__c._setup_settings._set_container_flag.call_deferred(_vbox, "fill")
		return

	if _findbar != null:
		_change_reparent(_findbar, _root)
		_change_reparent(_rtext, _root)
		__c._setup_settings._set_container_flag.call_deferred(_vbox, "fill")
		return

	if _parent is VSplitContainer:
		if _ce != null:
			_change_reparent(_parent, _root)
			__c._setup_settings._remove_theme_override_panel_focus(_ce)
			if _debug_manager._swaping_data_notif:
				_vbox._swaping_data(container_index, _scte_dict, "pre")

func _change_reparent(_node: Node, _new_parent: Node, _index: int = 0) -> void:
	_node.reparent(_new_parent)
	_node.get_parent().move_child(_node, _index)

#endregion
################################################################################
#region change_post

func _change_to_slected_new_script(_tab_index: int) -> void:
	if _script_item_list.item_count < _tab_index:
		#prints("[SMPDockContainer] return: %s, %s" % [
			#"sc_item_count: %s" % _script_item_list.item_count,
			#"tab_idx: %s" % _tab_index
			#])
		return

	if _dock_main._is_opened_script:
		return
	if _dock_main._is_closed_doc:
		return

	var _title: String = _plugin._tab_container.get_tab_title(_tab_index)
	if not _dock_main._container_list_dict.has(_title):
		return

	var _children: Array[Node] = _dock_main._container_list_dict[_title].get_children()
	var _names: Array[String] = []
	var _editor_root: Node

	if _script_item_list.item_count > _tab_index:
		if not _dock_item_bar._item_recent_menu._is_selected_press:
			_names = _dock_main._get_script_name(_tab_index)
		else:
			_names = _store_sc_names

	_editor_root = _plugin._tab_container.get_child(_tab_index)

	__notif_event_log("title", [_dock_main._store_focus_index, _tab_index, _title, _names], "283")
	__curr_data_debug_log(_dock_main._get_scte_arr(), "273")
	_vbox._is_increace_notif(_dock_main._is_opened_script)

	for child in _children:
	## type_script
		if child is VSplitContainer:
			if _vbox.get_child_count() > 0:
				return
			_change_reparent(child, _vbox)

			if _plugin._initial_load:
				_code_edit = _post_set_initial(_tab_index)
				_names = _store_sc_names
			else:
				if not _dock_item_bar._item_recent_menu._is_selected_press:
					_dock_item_bar._item_rich_name._set_rich_label_handle(_tab_index)
					_get_script_status()

			_post_set_swap(_tab_index, _title, child, _names)
			return

	## type_document
		elif child is RichTextLabel:
			if _vbox.get_child_count() > 0:
				return
			_set_data_doc_name(_editor_root)
			_type_editor_help(_editor_root, child, _tab_index)
			return

	## type_text_editor
		elif child.is_class(&"CodeTextEditor"):
			if _vbox.get_child_count() > 0:
				return
			_type_text_editor(_editor_root, child, _tab_index, _title)
			return

	_dock_main._store_focus_index = container_index

#endregion
################################################################################


##:: utility
################################################################################
#region _type_editor_help

func _type_editor_help(_editor_root: Node, child: RichTextLabel, _tab_index: int) -> void:
	var _findbar: Node
	for rchild in _editor_root.get_children():
		if rchild.is_class(&"FindBar"):
			_findbar = rchild
			break

	_change_reparent(_findbar, _vbox)
	_change_reparent(child, _vbox)

	_is_editor_misc = true
	_dock_item_bar._item_rich_name._set_rich_label_name(
		["", _editor_root.name]
		)
	_store_sc_names = ["", _editor_root.name]
	_post_set_swap_doc(
		_tab_index,
		_editor_root, null,
		child, _findbar,
		null, ["", _editor_root.name],
		)
	_dock_main._store_focus_index = container_index
	#print("rich_text_label: ", child)

#endregion
################################################################################
#region _type_text_editor

func _type_text_editor(
	_editor_root: Node, child: Node, _tab_index: int, _title: String
	) -> void:
	var _ce: Node
	for cchild in child.get_children():
		if cchild.is_class(&"CodeEdit"):
			_ce = cchild
			break
	if _ce == null:
		return
	_change_reparent(_ce, _vbox)
	_is_editor_misc = true

	_title = _script_item_list.get_item_text(_tab_index)
	_dock_item_bar._item_rich_name._set_rich_label_name(
		["", _title]
		)
	_store_sc_names = ["", _title]
	_post_set_swap_doc(
		_tab_index,
		_editor_root, child,
		null, null,
		_ce, ["", _editor_root.name],
		)
	_dock_main._store_focus_index = container_index
	#print("text_editor: ", _ce)

#endregion
################################################################################
#region _change_post_func

func _post_set_initial(_tindex: int) -> CodeEdit:
	var _scte: ScriptEditorBase = _plugin._tab_container.get_child(_tindex)
	var _ce: CodeEdit = __c._setup_utility._get_code_edit_from_base(_scte)
	var _ftype: int = __c._setup_project._get_focus_flash_type()
	__c._setup_settings._set_theme_override_panel_focus(_code_edit, _ftype)
	return _ce

func _post_set_swap(_tindex: int, _title: String, _child: VSplitContainer, _name: Array[String]) -> void:
	var _dict: Dictionary = _plugin._data_table(
		_dock_main._store_focus_index, _tindex,
		_dock_main._container_list_dict[_title], _child,
		_code_edit, _name,
		_store_script_path, _store_script_path_uid,
		)
	_scte_dict = _dict

	if _code_edit != null:
		_code_edit.grab_focus.call_deferred()

	if not _plugin._initial_load:
		_dock_item_bar._item_recent_menu._handle_menu_items(_dict)

	_dock_main._set_is_opened_script(false)
	__c._saveload_conf._save_parameter(_dock_main._store_focus_index, _scte_dict)
	_vbox._swaping_data(container_index, _dict, "post")

func _post_set_swap_doc(
	_tindex: int, _root: Node, _parent: Node,
	_rtext: RichTextLabel, _findbar: Node,
	_cedit: CodeEdit, _name: Array[String]
	) -> void:
	var _dict: Dictionary = _plugin._data_table_doc(
		_dock_main._store_focus_index, _tindex,
		_root, _parent,
		_rtext, _findbar,
		_cedit,	_name,
		)
	_scte_dict = _dict
	_dock_main._set_is_opened_script(false)
	_vbox._swaping_data_doc(container_index, _dict, "post")

#endregion
################################################################################


##:: signal
################################################################################
#region sig child_ordering_tree

func _on_child_order_changed() -> void:
	await get_tree().process_frame

	if _vbox.get_child_count() > 0:
		_set_visible_notepad(false)
		_dock_item_bar._item_add_button.set_visible(true)
		if not _plugin._is_once_call:
			_set_visible_ordering_child.call_deferred()
		__c._setup_settings._set_container_flag.call_deferred(_vbox, "exp")
		_doc_vscroll_search()
	else:
		_dock_item_bar._item_add_button.set_visible(true)
		_set_notepad_grab_focus()
		_set_visible_notepad.call_deferred(true)
		__c._setup_settings._set_container_flag.call_deferred(_vbox, "fill")

		if not _plugin._is_once_call:
			_set_visible_ordering_child.call_deferred()

			if not _is_editor_misc:
				self._dock_item_bar._item_rich_name._set_init_rich_name.call_deferred()

	_is_editor_misc = false
	_vbox._child_ordering_changed_notif(self)

func _handler_changed_container(_tab_index: int) -> void:
	if _dock_main._is_exited_misc:
		return
	if _get_dir_button_state():
		return
	_doc_order_store_data()

	if not _plugin._initial_load:
		if _check_is_loaded_script(_tab_index):
			_dock_main._is_tab_changed = false
			return
		if not _dock_main._is_opened_script:
			if not _dock_main._is_closed_script:
				_change_to_return_container()
				_scte_dict.clear()

		if _scte_dict.is_empty() and _vbox.get_child_count() == 0:
			_change_to_slected_new_script(_tab_index)
			_dock_main._is_tab_changed = false
		## to__on_child_exiting_tree

func _on_child_exiting_tree(_exit_node: Node) -> void:
	if _dock_main._is_plugin_actived:
		return
	_init_name_header()

	await get_tree().process_frame

	if is_instance_valid(_exit_node):
		_vbox._child_exiting_tree_notif(_exit_node)
		_check_is_connected(_exit_node, "disconnect")
	_code_edit = null

	if _get_dir_button_state():
		return

	if _plugin != null:
		_change_to_slected_new_script(_dock_main._store_tab_index)
		if _is_bools_existing_tree():
			_dock_item_bar._item_rich_name._set_rich_label_handle(_dock_main._store_tab_index)
		_dock_main._is_tab_changed = false
		_dock_main._set_is_remove_script.call_deferred(false)
		## to__on_child_entered_tree

func _on_child_entered_tree(_entered_node: Node) -> void:
	if _get_dir_button_state():
		return

	_vbox._child_entered_tree_notif(container_index, _entered_node)
	_check_is_connected(_entered_node, "connect")
	if _plugin._initial_load:
		_dock_item_bar._item_rich_name._set_rich_label_name(_store_sc_names)
	## child_swaping_end

func _is_bools_existing_tree() -> bool:
	if not _dock_main._is_opened_script:
		if not _dock_main._is_remove_script:
			if not _dock_main._is_closed_script:
				if not _dock_main._is_closed_doc:
					if not _is_editor_misc:
						return true
	return false

#endregion
################################################################################
#region _order_changed_util

func _init_name_header() -> void:
	for cont in _dock_main._get_mcontainer_arr():
		if cont._vbox.get_child_count() == 0:
			cont._dock_item_bar._item_rich_name._set_init_rich_name()

#endregion
################################################################################
#region _changed_item_button

func _set_visible_ordering_child() -> void:
	var _m2_recent: bool = _container2._dock_item_bar._item_recent_menu._is_selected_press

	if _container3._vbox.get_child_count() > 0:
		_container1._dock_item_bar._item_add_button.set_visible(false)
		_dock_main._dock_split2.set_visible(true)

		if not _m2_recent:
			_container2._dock_item_bar._item_add_button.set_visible(false)

		if not _container3.is_visible():
			_container3._change_to_return_container()
			__c._saveload_conf._clear_data_index.call_deferred(3)
			_container3._scte_dict.clear()
	else:
		if _container3.is_visible():
			_container1._dock_item_bar._item_add_button.set_visible(false)
			_container2._dock_item_bar._item_add_button.set_visible(false)

		else:
			_container1._dock_item_bar._item_add_button.set_visible(true)

			if _container2._vbox.get_child_count() > 0:
				_container2._dock_item_bar._item_add_button.set_visible(true)
			else:
				_container2._dock_item_bar._item_add_button.set_visible(false)


func _set_visible_ordering_child_load_initial() -> void:
	var _m2_recent: bool = _container2._dock_item_bar._item_recent_menu._is_selected_press

	if _container3._vbox.get_child_count() > 0:
		_container1._dock_item_bar._item_add_button.set_visible(false)
		_container2._dock_item_bar._item_add_button.set_visible(false)
		_dock_main._dock_split2.set_visible(true)

		if not _m2_recent:
			_container2._dock_item_bar._item_add_button.set_visible(false)
	else:
		if _container3.is_visible():
			_container1._dock_item_bar._item_add_button.set_visible(false)
			_container2._dock_item_bar._item_add_button.set_visible(false)
		else:
			_container1._dock_item_bar._item_add_button.set_visible(true)
			_container2._dock_item_bar._item_add_button.set_visible(true)

	if _container1._vbox.get_child_count() == 0:
		_container1._dock_item_bar._item_add_button.set_visible(false)

	if _container2._vbox.get_child_count() == 0:
		_container2._dock_item_bar._item_add_button.set_visible(false)

#endregion
################################################################################
#region __document_func

## _handler_changed_container
func _doc_order_store_data() -> void:
	if _dock_main._document_dict.has(_store_title):
		var _rtext: RichTextLabel = _scte_dict.get("rich_text", null)
		if _rtext != null:
			var _vscroll: VScrollBar = _rtext.get_v_scroll_bar()
			_dock_main._document_dict[_store_title] = _vscroll.value
			_vscroll.value = 0
			#prints("doc_exiting: ", _store_title, _dock_main._document_dict[_store_title])

## _on_child_order_changed
func _doc_vscroll_search() -> void:
	var _rtext := _scte_dict.get("rich_text", null)
	if _rtext != null:
		_rtext.set_visible(false)
		_opened_doc_hide_eye("hide")
		_timer_document._set_timer_start_auto(0.8, 1, 1, _on_timeout_doc_focus)

func _set_data_doc_name(_editor_root: Node) -> void:
	_store_title = _editor_root.name
	if not _dock_main._document_dict.has(_editor_root.name):
		_dock_main._document_dict[_editor_root.name] = -1
	#print("store_doc: ", _dock_main._document_dict)

func _on_timeout_doc_focus() -> void:
	_timer_document._init_timeout_auto()

	for _scte in _dock_main._get_scte_arr():
		var _root := _scte.get("root", null)
		var _rtext := _scte.get("rich_text", null)

		if _rtext != null:
			var _vscroll: VScrollBar = _rtext.get_v_scroll_bar()
			_rtext.set_visible(true)
			_opened_doc_hide_eye("show")

			if _root.is_class(&"EditorHelp"):
				if _root.name != "":
					_vscroll.value = _dock_main._document_dict[_root.name]
					_vscroll.set_deferred("value", _dock_main._document_dict[_root.name])

func _opened_doc_hide_eye(_select: String) -> void:
	match _select:
		"show":
			_set_visible_notepad(false)
			__c._setup_settings._set_container_flag.call_deferred(_vbox, "exp")
		"hide":
			_set_visible_notepad(true)
			__c._setup_settings._set_container_flag.call_deferred(_notepad_container, "exp")
			__c._setup_settings._set_container_flag.call_deferred(_vbox, "fill")

#endregion
################################################################################


##:: signal_connect
################################################################################
#region sig is_connected

func _check_is_connected(_node: Node, _type: String) -> void:
	if _node is VSplitContainer:
		var _scte := _node.get_parent()
		if _scte.is_class(&"ScriptTextEditor"):
			_code_edit = __c._setup_utility._get_code_edit_from_base(_scte)
		else:
			_code_edit = __c._setup_utility._find_node(_node, "CodeEdit")

		match _type:
			"disconnect":
				if _code_edit.is_connected("focus_entered", _on_focus_entered):
					_code_edit.disconnect("focus_entered", _on_focus_entered)
				if _code_edit.is_connected("gui_input", _on_gui_input):
					_code_edit.disconnect("gui_input", _on_gui_input)

			"connect":
				if not _code_edit.is_connected("focus_entered", _on_focus_entered):
					_code_edit.connect("focus_entered", _on_focus_entered)
				if not _code_edit.is_connected("gui_input", _on_gui_input):
					_code_edit.connect("gui_input", _on_gui_input)

		if is_instance_valid(_code_edit):
			_vbox._is_connected_notif(container_index, _code_edit, self)

	elif _node is RichTextLabel:
		_rich_text = _node
		match _type:
			"disconnect":
				if _rich_text.is_connected("focus_entered", _on_focus_entered):
					_rich_text.disconnect("focus_entered", _on_focus_entered)
				if _rich_text.is_connected("gui_input", _dock_main._event_dock_input._on_gui_input):
					_rich_text.disconnect("gui_input", _dock_main._event_dock_input._on_gui_input)
				if _rich_text.is_connected("gui_input", _dock_main._on_gui_input_code_edit):
					_rich_text.disconnect("gui_input", _dock_main._on_gui_input_code_edit)

			"connect":
				if not _rich_text.is_connected("focus_entered", _on_focus_entered):
					_rich_text.connect("focus_entered", _on_focus_entered)
				if not _rich_text.is_connected("gui_input", _dock_main._event_dock_input._on_gui_input):
					__c._setup_signal.connect_gui_input(_rich_text, _dock_main._event_dock_input._on_gui_input)
				if not _rich_text.is_connected("gui_input", _dock_main._on_gui_input_code_edit):
					__c._setup_signal.connect_gui_input(_rich_text, _dock_main._on_gui_input_code_edit)

	elif _node is CodeEdit:
		_te_cedit = _node
		match _type:
			"disconnect":
				if _te_cedit.is_connected("focus_entered", _on_focus_entered):
					_te_cedit.disconnect("focus_entered", _on_focus_entered)
				if _te_cedit.is_connected("gui_input", _dock_main._event_dock_input._on_gui_input):
					_te_cedit.disconnect("gui_input", _dock_main._event_dock_input._on_gui_input)
				if _te_cedit.is_connected("gui_input", _dock_main._on_gui_input_code_edit):
					_te_cedit.disconnect("gui_input", _dock_main._on_gui_input_code_edit)
			"connect":
				if not _te_cedit.is_connected("focus_entered", _on_focus_entered):
					_te_cedit.connect("focus_entered", _on_focus_entered)
				if not _te_cedit.is_connected("gui_input", _dock_main._event_dock_input._on_gui_input):
					__c._setup_signal.connect_gui_input(_te_cedit, _dock_main._event_dock_input._on_gui_input)
				if not _te_cedit.is_connected("gui_input", _dock_main._on_gui_input_code_edit):
					__c._setup_signal.connect_gui_input(_te_cedit, _dock_main._on_gui_input_code_edit)

func _check_is_connected_event_input(_type: String) -> void:
	var _scode_edit: CodeEdit = _notepad_container._code_notepad

	match _type:
		"disconnect":
			if _scode_edit.is_connected("gui_input", _dock_main._event_dock_input._on_gui_input):
				_scode_edit.disconnect("gui_input", _dock_main._event_dock_input._on_gui_input)
		"connect":
			if not _scode_edit.is_connected("gui_input", _dock_main._event_dock_input._on_gui_input):
				__c._setup_signal.connect_gui_input(
					_scode_edit, _dock_main._event_dock_input._on_gui_input
					)

func _boot_is_connected(_ce: CodeEdit, _type: String) -> void:
	if _type == "connect":
		if not _ce.is_connected("focus_entered", _on_focus_entered):
			_ce.connect("focus_entered", _on_focus_entered)

#endregion
################################################################################
#region sig On_focus

func _on_focus_entered() -> void:
	if not _dock_main._is_opened_script:
		_dock_main._store_focus_index = container_index
		_init_name_header()
		_focus_changed_for_item_list(_scte_dict)
		_vbox._focus_entered_notif(container_index, _scte_dict)

func _focus_changed_for_item_list(_dict: Dictionary) -> void:
	_dock_main._is_tab_changed = true
	if not _dict.is_empty():
		var _t_index: int = _dict.get("tab_index")
		var _cedit: CodeEdit = _dict.get("cedit", null)

		if _cedit != null:
			if _te_cedit != null:
				_check_is_connected(_te_cedit, "connect")
				__c._setup_settings._set_theme_override_panel_focus_misc(_te_cedit)

		elif _code_edit != null:
			_check_is_connected(_code_edit, "connect")
			var _ftype: int = __c._setup_project._get_focus_flash_type()
			__c._setup_settings._set_theme_override_panel_focus(_code_edit, _ftype)

		if _rich_text != null:
			_check_is_connected(_code_edit, "connect")
			__c._setup_settings._set_theme_override_panel_focus_misc(_rich_text)
			__c._setup_settings._set_theme_override_panel_normal_misc(_rich_text)

		if _dock_main._store_tab_index != _t_index:
			_dock_main._store_tab_index = _t_index
			_script_item_list.item_selected.emit(_t_index)
			_dock_main._is_tab_changed = false
		else:
			_dock_main._is_tab_changed = false

#endregion
################################################################################

##:: signal_gui
################################################################################
#region sig On_gui_input

func _on_gui_input(_event: InputEvent) -> void:
	if _event is InputEventMouseButton:
		if _event.pressed and _event.button_index == MOUSE_BUTTON_RIGHT:
			var _root := _scte_dict.get("root", null)
			if _root != null:
				for child in _root.get_children():
					if child is PopupMenu:
						var _mouse_pos := get_local_mouse_position()
						var _pos := get_screen_position()
						var _offset := Vector2(0, 15)
						child.position = _mouse_pos + _pos + _offset
						return

#endregion
################################################################################


##:: save
################################################################################
#region Saving_params

func _set_expand_state(_exp_button: bool) -> void:
	if _vbox.get_child_count() > 0:
		__c._saveload_conf._save_parameter_type_value(
			container_index, __c._setup_settings._save_key_name["expand"], _exp_button
			)

func _set_vert_state(_vert_button: bool) -> void:
	__c._saveload_conf._save_parameter_type_value(
		container_index, __c._setup_settings._save_key_name["vert"], _vert_button
		)

func _set_title_name(_tindex: int, _load_value: Array[String] = []) -> void:
	var _sc_names: Array[String]

	if _tindex != -1:
		_sc_names = _dock_main._get_script_name(_tindex)
	else:
		_sc_names = _load_value

	if not _sc_names.is_empty():
		self._dock_item_bar._item_rich_name._set_rich_label_name(_sc_names)

	if not _sc_names.is_empty():
		__c._saveload_conf._save_parameter_type_value(
			container_index, __c._setup_settings._save_key_name["s_name"], _sc_names
		)

func _set_font_size(_size: int) -> void:
	if _code_edit != null:
		self._dock_item_bar._item_text_size_button._set_rich_text(_size)
		__c._setup_settings._set_theme_override_font_size(_code_edit, _size)
		__c._saveload_conf._save_parameter_type_value(
			container_index, __c._setup_settings._save_key_name["f_size"], _size
			)

func _set_wrap_mode(_type: bool) -> void:
	if _code_edit == null:
		_code_edit = _get_vbox_child_ce()
	if _code_edit != null:
		var _b: int = _type
		_code_edit.set_line_wrapping_mode(_b)
		__c._saveload_conf._save_parameter_type_value(
			container_index, __c._setup_settings._save_key_name["boundary"], _type
			)

func _set_minimap_draw(_active: bool) -> void:
	if _code_edit == null:
		_code_edit = _get_vbox_child_ce()
	if _code_edit != null:
		_code_edit.minimap_draw = _active
		__c._saveload_conf._save_parameter_type_value(
			container_index, __c._setup_settings._save_key_name["m_map"], _active
			)

func _set_add_state(_active: bool) -> void:
	if _get_dir_button_state():
		return
	if _code_edit == null:
		_code_edit = _get_vbox_child_ce()
	if _code_edit != null:
		_dock_item_bar._item_add_button._is_add_button = _active
		__c._saveload_conf._save_parameter_type_value(
			container_index, __c._setup_settings._save_key_name["add"], _active
			)

#endregion
################################################################################


##:: debug
################################################################################
#region __notif

func __curr_data_debug_log(_data_arr: Array, _line: String) -> void:
	if not _debug_manager._current_dicts:
		return
	for dict: Dictionary in _data_arr:
		var _notif: Array = _debug_manager._data_dict_arr_notif(dict)
		_debug_manager._log_signal("rich", self, "current_dict", _notif, _line)

func __notif_event_log(_log: String, _vari: Array, _line: String) -> void:
	if _debug_manager._event_log:
		_debug_manager._log_signal("pri", self, _log, _vari, _line)

#endregion
################################################################################

