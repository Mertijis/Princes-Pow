@tool
class_name SMPLineEditSelected
extends LineEdit


""" class """
var __c: SMPClassManagers
var _find_popup_panel: SMPFindPopupPanel


var _store_path: String:
	set(_value):
		_store_path = _value
	get:
		return _store_path


################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item
			elif item is SMPFindPopupPanel:
				_find_popup_panel = item

#endregion
################################################################################
#region _set_status

func _set_line_edit_store_path(_path: String) -> void:
	if _path == "":
		return
	_store_path = _path
	self.text = _path.get_file()
	_find_popup_panel._buttons_disabled_status(false, _path, "select")
	call_deferred_thread_group("_visible_script_status", _path)

func _clear_store_path() -> void:
	self.text = ""
	_store_path = ""
	_find_popup_panel._buttons_disabled_status(true, "", "init")

func _get_slected_store_path() -> String:
	return _store_path

#endregion
################################################################################
#region _visible_label_hover

func _visible_script_status(_path: String) -> void:
	if _path == "":
		return
	var _res: Resource = ResourceLoader.load(
		_path, "Script", ResourceLoader.CACHE_MODE_REUSE
		)
	await get_tree().process_frame
	if _res is GDScript and is_instance_valid(_res):
		var _extends: String = _res.get_instance_base_type()
		var _global_name: String = _res.get_global_name()

		_find_popup_panel._label_class_name._set_rich_text_insert(_global_name)
		_find_popup_panel._label_extends._set_rich_text_insert(_extends)

#endregion
################################################################################

