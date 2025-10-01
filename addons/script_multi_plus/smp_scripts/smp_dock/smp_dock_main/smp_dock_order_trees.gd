@tool
class_name SMPDockOrderTrees
extends Node


""" class """
var __c: SMPClassManagers
var _debug_manager: SMPDebugManager
var _plugin: ScriptMultiPlusPlugin
var _dock_main: ScriptMultiPlusDock

var _timer_opened: SMPTimerUtility
var _timer_closed: SMPTimerUtility
var _timer_remove: SMPTimerUtility

var _remove_focus_index: int = -1
var _entered_tindex: int = -1


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
			elif item is ScriptMultiPlusDock:
				_dock_main = item
			elif item is SMPDebugManager:
				_debug_manager = item

	_timer_opened = SMPTimerUtility.new(_dock_main)
	_timer_closed = SMPTimerUtility.new(_dock_main)
	_timer_remove = SMPTimerUtility.new(_dock_main)

#endregion
################################################################################


##:: order_changed
################################################################################
#region sig_ order_changed

func _moved_script_order() -> void:
	__c._saveload_filesystem._update_move_script_list()

#endregion
################################################################################


##:: entered
################################################################################
#region sig_ child_entered

func _child_entered_tree(_entered_node: Node) -> void:
	if _entered_node.is_class(&"ScriptTextEditor"):
		_entered_child_increase(_entered_node, "scte")
	elif _entered_node.is_class(&"EditorHelp"):
		_entered_child_increase(_entered_node, "misc_doc")
	elif _entered_node.is_class(&"TextEditor"):
		_entered_child_increase(_entered_node, "misc_text")

#endregion
################################################################################
#region _child_entered

func _entered_child_increase(_entered_node: Node, _type: String) -> void:
	match _type:
		"scte":
			_get_entered_index(_entered_node)
			_opened_editor_item(_entered_node)
		"misc_doc":
			_get_entered_doc_index(_entered_node)
			_opened_editor_item(_entered_node)
		"misc_text":
			_get_entered_index(_entered_node)
			_opened_editor_item(_entered_node)
	__notif_entered(_entered_node, _type, "82")

func _opened_editor_item(_entered_node: Node) -> void:
	_dock_main._update_container_list()
	_dock_main._caret_changed_position()
	_dock_main._store_tab_index = _entered_tindex
	_timer_opened._set_timer_start_auto(0.4, 1, 1, _on_timer_timeout_opened)

func _on_timer_timeout_opened() -> void:
	_timer_opened._init_timeout_auto()
	_dock_main._set_is_opened_script(false)
	_dock_main._event_button_num = 0
	_plugin._tab_container.tab_changed.emit(_entered_tindex)

#endregion
################################################################################
#region _child_entered_util

func _get_entered_index(_entered_node: Node) -> void:
	var _container_children: Array[Node] = _plugin._tab_container.get_children()
	for child: Node in _container_children:
		if child.name == _entered_node.name:
			_entered_tindex = child.get_index()
			return

func _get_entered_doc_index(_entered_node: Node) -> void:
	var _count: int = 0
	if _dock_main._script_item_list.item_count > 0:
		_count = _dock_main._script_item_list.item_count
	for i: int in range(_count):
		var _name: String = _dock_main._script_item_list.get_item_text(i)
		if _name == _entered_node.name:
			_entered_tindex = i
			return

#endregion
################################################################################


##:: exiting
################################################################################
#region sig_ child_exiting

func _child_exiting_tree(_exiting_node: Node) -> void:
	if _exiting_node.is_class(&"ScriptTextEditor"):
		_exiting_return_position(_exiting_node, "scte")
	elif _exiting_node.is_class(&"EditorHelp"):
		_exiting_return_position(_exiting_node, "misc_doc")
	elif _exiting_node.is_class(&"TextEditor"):
		_exiting_return_position(_exiting_node, "misc_text")

	if _dock_main._is_exited_misc:
		return
	_exiting_return_not_assigned(_exiting_node)

## When not assigned
func _exiting_return_not_assigned(_exiting_node: Node) -> void:
	for scte: Dictionary in _dock_main._get_scte_arr():
		var _root := scte.get("root", null)
		if _root != _exiting_node:
			_sc_closed_after_end_neg()
	_dock_main._set_is_exited_misc(false)

#endregion
################################################################################
#region _child_exiting

func _exiting_return_position(_exiting_node: Node, _type: String) -> void:
	for scte: Dictionary in _dock_main._get_scte_arr():
		var _cont: Node
		var _root := scte.get("root", null)
		var _findex: int = scte.get("focus_index", -1)

		if _root == _exiting_node:
			_cont = _dock_main._get_focus_mcontainer(_findex)

			if _cont == null:
				return
			if _cont._vbox.get_child_count() > 0:
				for vchild in _cont._vbox.get_children():
					__notif_exiting(_exiting_node, _type, "162")

					match _type:
						"scte":
							if vchild is VSplitContainer:
								_dock_main._set_is_exited_misc(true)
								_exiting_node_queue_free(_exiting_node, vchild, scte, _type)
						"misc_doc":
							if vchild is RichTextLabel:
								_dock_main._set_is_exited_misc(true)
								_exiting_node_queue_free(_exiting_node, vchild, scte, _type)
						"misc_text":
							if vchild is CodeEdit:
								_dock_main._set_is_exited_misc(true)
								_exiting_node_queue_free(_exiting_node, vchild, scte, _type)

#endregion
################################################################################

##:: exiting_utility
################################################################################
#region _child_exiting_return

func _exiting_node_queue_free(
	_exiting_node: Node, _vchild: Node, _dict: Dictionary, _type: String
	) -> void:
	var _findex: int = _dict.get("focus_index", -1)
	var _root: Node = _dict.get("root", null)
	var _parent: Node = _dict.get("parent", null)
	var _findbar: Node = _dict.get("findbar", null)
	var _cedit: CodeEdit = _dict.get("code_edit", null)

	if _root == null:
		return
	if _exiting_node.name == _root.name:
		_dock_main._is_closed_doc = true
		_dock_main._set_is_exited_misc(true)

		var _cont := _dock_main._get_focus_mcontainer(_findex)
		if _cont._te_cedit != null:
			_cont._te_cedit = null
		if _cont._rich_text != null:
			_cont._rich_text = null

		if _findbar != null:
			_findbar.queue_free()
		if _cedit != null:
			_cont._check_is_connected(_cedit, "disconnect")
			_cont._code_edit == null

		_remove_focus_index = _findex
		_vchild.queue_free()
		_cont._scte_dict.clear()
		__c._saveload_conf._clear_data_index(_cont.container_index)
		_timer_remove._set_timer_start_auto(
			0.6, 1, 1, _on_timeout_remove_doc.bind(_cont, _type)
			)

#endregion
################################################################################
#region _timeout_exiting

func _on_timeout_remove_doc(_cont: SMPDockContainer, _type: String) -> void:
	_timer_remove._init_timeout_auto()
	if _remove_focus_index == _cont.container_index:
		_cont._dock_item_bar._item_rich_name._set_init_rich_name()
		__c._saveload_conf._clear_data_index(_cont.container_index)
	_dock_main._is_closed_doc = false

	match _type:
		"scte":
			_on_sc_closed_after()

		"misc_doc", "misc_text":
			if _remove_focus_index != -1:
				var _fcont := _dock_main._get_focus_mcontainer(_remove_focus_index)
				_fcont._notepad_container._code_notepad.focus_entered.emit()
				_fcont._set_notepad_grab_focus()
			_dock_main._deselect_sc_list()
			_sc_closed_after_end()
			return

	if _dock_main._script_item_list.item_count != 1:
		_dock_main._deselect_sc_list()

func _on_sc_closed_after() -> void:
	await _dock_main.get_tree().process_frame
	if _remove_focus_index != -1:
		_dock_main._store_focus_index = _remove_focus_index
		var _cont := _dock_main._get_focus_mcontainer(_remove_focus_index)
		_cont._notepad_container._code_notepad.focus_entered.emit()
		_cont._set_notepad_grab_focus()
	_sc_closed_after_end()

#endregion
################################################################################
#region _timeout_exiting_end

func _sc_closed_after_end() -> void:
	_dock_main._set_init_stat()
	_dock_main._set_is_file_removed(false)
	_dock_main._set_is_closed_script(false)
	_dock_main._set_is_exited_misc(false)
	_dock_main._update_container_list()
	_closed_after_log("271")
	_remove_focus_index = -1
	await _dock_main.get_tree().process_frame
	_dock_main._caret_changed_position()
	__c._saveload_filesystem._update_move_script_list()

	if _dock_main._script_item_list.item_count == 1:
		_dock_main._plugin._tab_container.tab_changed.emit.call_deferred(0)


func _sc_closed_after_end_neg() -> void:
	_dock_main._set_is_file_removed(false)
	_dock_main._set_is_closed_script(false)
	_dock_main._set_is_exited_misc(false)
	_dock_main._update_container_list()
	_closed_after_log("282")
	_dock_main._caret_changed_position()
	_plugin._loading_rebuild_recent_data_index("recent")

#endregion
################################################################################


##:: closed_script
################################################################################
#region closed_script_process

func _closed_reparent(_path: String, _data: Dictionary) -> void:
	for key: int in _data:
		if _path == _data[key].get("script_path", ""):
			var _scte := _dock_main._get_focus_scte_dict(key)
			var _cont := _dock_main._get_focus_mcontainer(key)
			var _root := _scte.get("root", null)
			var _parent := _scte.get("parent", null)
			var _findbar := _scte.get("findbar", null)
			var _rtext := _scte.get("rich_text", null)
			_dock_main._store_focus_index = _cont.container_index

			if _findbar != null:
				_cont._change_reparent(_findbar, _root)
				_cont._change_reparent(_rtext, _root)
				return

			if _root != null and _parent != null:
				_cont._change_reparent(_parent, _root)
				return

func _closed_script(_path: String, _type: String) -> void:
	var _sdata: Dictionary[int, Dictionary] = _get_closed_data_index(_path)

	for key: int in _sdata:
		if key == _dock_main._store_focus_index:
			var _scte := _dock_main._get_focus_scte_dict(key)
			var _cont := _dock_main._get_focus_mcontainer(key)
			var _findex: int = _scte.get("focus_index", -1)
			var _root := _scte.get("root", null)
			var _parent := _scte.get("parent", null)

			if _root != null and _parent != null:
				_cont._change_reparent(_parent, _root)
				_cont._check_is_connected(_scte["code_edit"], "disconnect")
				_cont._code_edit == null

			_remove_focus_index = _findex
			_log_closed_script(_scte, "329")
			_scte.clear()
			__c._saveload_conf._clear_data_index(key)
			break

	_dock_main._set_is_file_removed(false)
	_dock_main._set_is_closed_script(false)
	_timer_closed._init_timeout_auto()

	match _type:
		"type_1":
			_dock_main._update_container_list()
			_dock_main._caret_changed_position()
		#"type_2":
			#_sc_closed_after_end()

	_plugin._loading_rebuild_recent_data_index("recent")

#endregion
################################################################################
#region _closed_script_utility

func _get_closed_data(_path: String) -> Dictionary[int, Dictionary]:
	for idx: String in __c._saveload_conf._indexs:
		var _data: Dictionary = __c._saveload_conf._get_save_data(idx)
		if not _data.is_empty():
			for key: int in _data:
				if _path == _data[key].get("script_path", ""):
					return _data.duplicate()
	return {}

func _get_closed_data_index(_path: String) -> Dictionary[int, Dictionary]:
	for idx: String in __c._saveload_conf._indexs:
		var _kint: int = idx.to_int()
		if _kint == _dock_main._store_focus_index:
			var _sdata: Dictionary = __c._saveload_conf._get_save_data(idx)
			if not _sdata.is_empty():
				return _sdata.duplicate()
	return {}

#endregion
################################################################################

##:: debug
################################################################################
#region debug_

func _closed_after_log(_line: String) -> void:
	if not _debug_manager._script_closed:
		return
	var _data_arr: Array = [
		_dock_main._mcontainer_1._scte_dict,
		_dock_main._mcontainer_2._scte_dict,
		_dock_main._mcontainer_3._scte_dict
		]
	for dict: Dictionary in _data_arr:
		var _notif: Array = _debug_manager._data_dict_arr_notif(dict)
		_debug_manager._log_signal(
			"rich", self, "on_script_closed_save_data", _notif, _line,
			)

func _log_closed_script(_scte: Dictionary, _line: String) -> void:
	if not _debug_manager._script_closed:
		return
	var _notif: Array = []
	_notif = _debug_manager._data_dict_arr_notif(_scte)
	_debug_manager._log_signal("rich", self, "script_closed", _notif, _line)

#endregion

#region __notif

func __notif_log(_select: String, _log: String, _type_node: Node, _line: String) -> void:
	if not _debug_manager._script_opened:
		return
	_debug_manager._log_signal(
		"pri", self, _select, [_log, _type_node], _line
		)

func __notif_entered(_entered_node: Node, _type: String, _line: String) -> void:
	if not _debug_manager._script_opened:
		return
	match _type:
		"scte":
			__notif_log("script_opened", "child_entered_scte: ", _entered_node, _line)
		"misc_doc":
			__notif_log("script_opened", "child_entered_editor_help: ", _entered_node, _line)
		"misc_text":
			__notif_log("script_opened", "child_entered_text_editor: ", _entered_node, _line)

func __notif_exiting(_exiting_node: Node, _type: String, _line: String) -> void:
	if not _debug_manager._script_closed:
		return
	match _type:
		"scte":
			__notif_log("script_closed", "child_exiting_scte: ", _exiting_node, _line)
		"misc_doc":
			__notif_log("script_closed", "child_exiting_editor_help: ", _exiting_node, _line)
		"misc_text":
			__notif_log("script_closed", "child_exiting_text_editor: ", _exiting_node, _line)

#endregion
################################################################################

