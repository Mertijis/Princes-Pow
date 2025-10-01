@tool
class_name SMPDocumentHelper
extends Node


""" class """
var __c: SMPClassManagers
var _plugin: ScriptMultiPlusPlugin
var _dock_main: ScriptMultiPlusDock
#var _debug_manager: SMPDebugManager

""" timer """
var _timer_goto_help: SMPTimerUtility
var _timer_goto_help_after: SMPTimerUtility

""" doc_item """
var _store_goto_help_meth: String = ""
var _select_goto_help: String = ""

var _call_count_0: int = 0
var _call_count_1: int = 0


##:: setup
################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item
			elif item is ScriptMultiPlusPlugin:
				_plugin = item
			elif item is ScriptMultiPlusDock:
				_dock_main = item
			#elif item is SMPDebugManager:
				#_debug_manager = item

	_timer_goto_help = SMPTimerUtility.new(_dock_main)
	_timer_goto_help_after = SMPTimerUtility.new(_dock_main)

#endregion
###############################################################################


##:: signal goto_help
###############################################################################
#region sig_ goto_help#

func _what_go_to_help(_what: String) -> void:
	#print("what: ", _what)
	_store_goto_help_meth = _what

	var _split := _what.split(":")
	if _split.size() > 1:
		_select_goto_help = _split[1]

	_timer_goto_help._set_timer_start_auto(0.2, 1, 1, _on_timeout_goto_help)


func _on_timeout_goto_help() -> void:
	#prints("store_goto_name: ", _store_goto_help_meth, _dock_main._is_open_doc)

	if _call_count_0 > 6:
		_dock_main._set_is_open_doc(false)
		_plugin._script_editor.goto_help(_store_goto_help_meth)

		_timer_goto_help._init_timeout_auto()
		_call_count_0 = 0
	_call_count_0 += 1

	if _dock_main._is_open_doc:
		_timer_goto_help._init_timeout_auto()
		if _is_goto_global():
			return


func _is_goto_global() -> bool:
	if _select_goto_help.begins_with("@"):
		if _dock_main._script_item_list.item_count > 0:
			var _count: int = _dock_main._script_item_list.item_count

			for idx: int in range(_count):
				var _name: String = _dock_main._script_item_list.get_item_text(idx)

				if _name == _select_goto_help:
					_timer_goto_help_after._set_timer_start_auto(
					0.4, 1, 1, _on_timeout_goto_help_after.bind(idx)
					)
					#prints("name: ", idx, _name, _store_goto_help_meth)
					return true
	return false


func _on_timeout_goto_help_after(_index: int) -> void:
	_dock_main._set_is_open_doc(false)
	_plugin._tab_container.tab_changed.emit(_index)
	_plugin._script_editor.goto_help(_store_goto_help_meth)

	if _call_count_1 > 1:
		_timer_goto_help_after._init_timeout_auto()
		_call_count_1 = 0
	_call_count_1 += 1

#endregion
################################################################################


##:: signal_search_help
################################################################################
#region sig_help_search

func _on_open_pressed_ehelp() -> void:
	_search_handle_ehelp()

func _on_text_submitted_ehelp(_text: String) -> void:
	_search_handle_ehelp()

func _on_item_actived_ehelp() -> void:
	_search_handle_ehelp()

func _on_item_selected_ehelp() -> void:
	_store_goto_help_meth = _selected_item_ehelp()

func _search_handle_ehelp() -> void:
	if _store_goto_help_meth != "":
		_what_go_to_help(_store_goto_help_meth)
	else:
		_what_go_to_help(_selected_item_ehelp())

func _selected_item_ehelp() -> String:
	var _selected_item: TreeItem = _plugin._ehelp_tree.get_selected()
	if _selected_item:
		var _text: String = _selected_item.get_text(0)
		var _meta := _selected_item.get_metadata(0)
		#print("selected: ", _text, _meta)
		return _meta
	return ""

#endregion
################################################################################
#region sig_is_connected_ehelp

func _check_signal_ehelp(_type: String) -> void:
	match _type:
		"disconnect":
			if _plugin._ehelp_tree.item_activated.is_connected(_on_item_actived_ehelp):
				_plugin._ehelp_tree.item_activated.disconnect(_on_item_actived_ehelp)
				_plugin._ehelp_tree.item_selected.disconnect(_on_item_selected_ehelp)
				_plugin._ehelp_open_button.pressed.disconnect(_on_open_pressed_ehelp)
				_plugin._ehelp_line_edit.text_submitted.disconnect(_on_text_submitted_ehelp)

		"connect":
			if not _plugin._ehelp_tree.item_activated.is_connected(_on_item_actived_ehelp):
				_plugin._ehelp_tree.item_activated.connect(_on_item_actived_ehelp)
				_plugin._ehelp_tree.item_selected.connect(_on_item_selected_ehelp)
				_plugin._ehelp_open_button.pressed.connect(_on_open_pressed_ehelp)
				_plugin._ehelp_line_edit.text_submitted.connect(_on_text_submitted_ehelp)

#endregion
################################################################################

