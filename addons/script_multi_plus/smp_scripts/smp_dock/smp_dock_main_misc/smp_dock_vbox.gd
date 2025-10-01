@tool
class_name SMPDockVbox
extends VBoxContainer


""" class """
var __c: SMPClassManagers
var _debug_manager: SMPDebugManager
var _plugin: ScriptMultiPlusPlugin
var _dock_main: ScriptMultiPlusDock

var __end: String = "[/color]"
var __icolor: String = "[color=orange]"
var __tcolor: String = "[color=deep_pink]"
var __bcolor: String = "[color=medium_orchid]"
var __scolor: String = "[color=khaki]"
var __ncolor: String = "[color=pale_green]"


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
			elif item is SMPClassManagers:
				__c = item

#endregion
################################################################################
#region notif_child_order

func _child_ordering_changed_notif(_parent: SMPDockContainer) -> void:
	if not _debug_manager._child_ordering_notif:
		return
	var __notif: Array = [
		"parent: %s%s%s" % [__ncolor, _parent.name, __end],
		"child_count: %s%s%s" % [__icolor, _parent._vbox.get_child_count(), __end],
	]
	_debug_manager._log_signal("rich", self, "child_orderin", __notif, "53")


func _child_exiting_tree_notif(_exit_node: Node) -> void:
	if not _debug_manager._child_exiting_notif:
		return

	var _code_edit: Node = __c._setup_utility._find_node(_exit_node, "CodeEdit")

	if _code_edit == null:
		_code_edit = _exit_node

	var __notif: Array = [
		"root: %s%s%s" % [__ncolor, _exit_node.get_parent().name, __end],
		"exit: %s%s%s" % [__ncolor, _exit_node.name, __end],
		"%s%s%s" % [__ncolor, _code_edit.name, __end],
	]
	_debug_manager._log_signal("rich", self, "child_exiting", __notif, "69")


func _child_entered_tree_notif(_index: int, _entered_node: Node) -> void:
	if not _debug_manager._child_entered_notif:
		return
	var _vbox := _entered_node.get_parent()
	var _code_edit: Node = __c._setup_utility._find_node(_entered_node, "CodeEdit")

	if _code_edit == null:
		_code_edit = _entered_node

	var __notif: Array = [
		"cont_idx: %s%s%s" % [__icolor, _index, __end],
		"parent: %s%s%s" % [__ncolor, _entered_node.get_parent().name, __end],
		"%s%s%s" % [__ncolor, _code_edit.name, __end],
		"%s%s%s" % [__ncolor, _entered_node.name, __end],
	]
	_debug_manager._log_signal("rich", self, "child_entered", __notif, "84")


func _is_connected_notif(_index: int, _ce: CodeEdit, _parent: SMPDockContainer) -> void:
	if not _debug_manager._is_connected_notif:
		return
	var __notif: Array = [
		"cont_idx: %s%s%s" % [__icolor, _index, __end],
		"f_entered: %s%s%s" % [__bcolor, _ce.is_connected("focus_entered", _parent._on_focus_entered), __end],
		"%s%s%s" % [__ncolor, _ce.name, __end],
	]
	_debug_manager._log_signal("rich", self, "ce__connected", __notif, "95")

func _is_connected_notif_doc(_index: int, _ce: Node, _parent: SMPDockContainer) -> void:
	if not _debug_manager._is_connected_notif:
		return
	var __notif: Array = [
		"cont_idx: %s%s%s" % [__icolor, _index, __end],
		"f_entered: %s%s%s" % [__bcolor, _ce.is_connected("focus_entered", _parent._on_focus_entered), __end],
		"%s%s%s" % [__ncolor, _ce.name, __end],
	]
	_debug_manager._log_signal("rich", self, "ce__connected", __notif, "102")

#endregion
################################################################################
#region notif_focus_entered

func _is_increace_notif(_increase: bool) -> void:
	if not _debug_manager._focus_entered_notif:
		return
	var __notif: Array = [
		"is_increase: %s%s%s" % [__bcolor, _increase, __end],
	]
	_debug_manager._log_signal("rich", self, "focus_entered", __notif, "107")

func _focus_entered_notif(_index: int, _scte: Dictionary) -> void:
	if not _debug_manager._focus_entered_notif:
		return
	if not is_instance_valid(_scte):
		return

	var __notif: Array = [
		"focus_idx: %s%s%s" % [__icolor, _index, __end],
		"tab_index: %s%s%s" % [__icolor, _scte["tab_index"], __end],
		"root: %s%s%s" % [__ncolor, _scte["root"].name, __end],
		"parent: %s%s%s" % [__ncolor, _scte["parent"].name, __end],
		"code_edit: %s%s%s" % [__ncolor, _scte["code_edit"].name, __end],
		"sc_name: %s%s%s" % [__scolor, _scte["sc_name"], __end],
		"script_path: %s%s%s" % [__scolor, _scte["script_path"], __end],
		"uid_path: %s%s%s" % [__scolor, _scte["uid_path"], __end],
	]
	_debug_manager._log_signal("rich", self, "focus_entered", __notif, "125")

#endregion
################################################################################

func _swaping_data(_index: int, _scte: Dictionary, _type: String) -> void:
	if not _debug_manager._swaping_data_notif:
		return

	var _sub_name: String = "exited::"
	match _type:
		"post":
			_sub_name = "entered::"

	var __notif: Array = [
		"%s %s%s%s" % [_sub_name, __tcolor, _scte["sc_name"], __end],
		"focus_idx: %s%s%s" % [__icolor, _index, __end],
		"tab_index: %s%s%s" % [__icolor, _scte["tab_index"], __end],
		"root: %s%s%s" % [__ncolor, _scte["root"].name, __end],
		"parent: %s%s%s" % [__ncolor, _scte["parent"].name, __end],
		"code_edit: %s%s%s" % [__ncolor, _scte["code_edit"].name, __end],
		"sc_name: %s%s%s" % [__scolor, _scte["sc_name"], __end],
		"script_path: %s%s%s" % [__scolor, _scte["script_path"], __end],
		"uid_path: %s%s%s" % [__scolor, _scte["uid_path"], __end],
	]
	_debug_manager._log_signal("rich", self, "swap_data_%s" % _type, __notif, "143")

################################################################################

func _swaping_data_doc(_index: int, _scte: Dictionary, _type: String) -> void:
	if not _debug_manager._swaping_data_notif:
		return

	var _sub_name: String = "exited::"
	match _type:
		"post":
			_sub_name = "entered::"

	var _root := _scte.get("root", null)
	var _parent := _scte.get("parent", null)
	var _rtext := _scte.get("rich_text", null)
	var _cedit := _scte.get("cedit", null)

	if _parent != null: _parent = _parent.name
	if _rtext != null: _rtext = _rtext.name
	if _cedit != null: _cedit = _cedit.name

	var __notif: Array = [
		"%s %s%s%s" % [_sub_name, __tcolor, _scte["sc_name"], __end],
		"focus_idx: %s%s%s" % [__icolor, _index, __end],
		"tab_index: %s%s%s" % [__icolor, _scte["tab_index"], __end],
		"root: %s%s%s" % [__ncolor, _root, __end],
		"parent: %s%s%s" % [__ncolor, _parent, __end],
		"code_edit: %s%s%s" % [__ncolor, _cedit, __end],
	]
	_debug_manager._log_signal("rich", self, "swap_data_%s" % _type, __notif, "171")

