@tool
class_name SMPDockNotePad
extends VBoxContainer


""" class """
var __c: SMPClassManagers
var _plugin: ScriptMultiPlusPlugin
var _dock_main: ScriptMultiPlusDock

@onready var _code_notepad: CodeEdit = %CodeNotepad


################################################################################
#region _set_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is ScriptMultiPlusPlugin:
				_plugin = item
			elif item is ScriptMultiPlusDock:
				_dock_main = item
			elif item is SMPClassManagers:
				__c = item


	_set_ready_signal()
	var _ftype: int = __c._setup_project._get_focus_flash_type()
	__c._setup_settings._set_theme_override_panel_focus(_code_notepad, _ftype)

#endregion
################################################################################
#region set_status

func _set_ready_signal() -> void:
	__c._setup_signal.connect_focus_entered(_code_notepad, _on_focus_entered)

#endregion
################################################################################

func _on_focus_entered() -> void:
	var _owner: SMPDockContainer = _get_owner_node()
	_dock_main._store_focus_index = _owner.container_index
	_owner._check_is_connected_event_input("connect")
	#prints("on_focus_entered: ", _owner.container_index, _dock_main._store_focus_index)


func _set_notepad_text(_text: String) -> void:
	_code_notepad.text = _text


func _set_past_end(_active: bool) -> void:
	_code_notepad.scroll_past_end_of_file = _active


func _get_owner_node() -> SMPDockContainer:
	return _code_notepad.get_parent().owner


