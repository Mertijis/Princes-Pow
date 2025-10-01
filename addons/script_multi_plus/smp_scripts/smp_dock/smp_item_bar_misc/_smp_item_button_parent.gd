@tool
class_name SMPItemButtonParent
extends Button


""" class """
var __c: SMPClassManagers
var _debug_manager: SMPDebugManager
var _plugin: ScriptMultiPlusPlugin
var _dock_main: ScriptMultiPlusDock


################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if _plugin == null and item is ScriptMultiPlusPlugin:
				_plugin = item
			elif _dock_main == null and item is ScriptMultiPlusDock:
				_dock_main = item
			elif _debug_manager == null and item is SMPDebugManager:
				_debug_manager = item
			elif __c == null and item is SMPClassManagers:
				__c = item

		_set_ready_status()
		_set_ready_signal()

#endregion
################################################################################
#region _necessary_func

func _set_ready_signal() -> void: pass

func _set_ready_status() -> void: pass

func _set_vert_handle(_key_index: int = -1, _load_set: bool = false) -> void: pass

func _set_text_size_handle(_key_int: int = -1, _load_set: int = -1) -> void: pass

func _set_boundary_handle(_key_index: int = -1, _load_set: bool = false) -> void: pass

func _set_minimap_handle(_key_index: int = -1, _load_set: bool = false) -> void: pass

func _set_add_handle(_key_index: int = -1, _load_set: bool = false) -> void: pass

func _set_rich_label_handle(_tindex: int, _load_value: Array[String] = []) -> void: pass

func _set_rich_label_name(_text: Array[String]) -> void: pass

#endregion
################################################################################
#region _load_status

func _loading_buttons_data(_load_data: Dictionary, _key_index: String) -> void:
	if __c._godot_conf.has_section_key(__c._setup_settings._section, _key_index):
		var _key_int: int = _key_index.to_int()

		for key: String in _load_data[_key_int]:
			var _load_value: Variant = _load_data[_key_int][key]

			match key:
				"minimap":
					_set_minimap_handle(_key_int, _load_value)
				"vert_button":
					_set_vert_handle(_key_int, _load_value)
				"wrap_mode":
					_set_boundary_handle(_key_int, _load_value)
				"add_button":
					_set_add_handle(_key_int, _load_value)
				#"font_size":
					#_set_text_size_handle(_key_int, _load_value)
				#"sc_name":
					#pass
					#_set_rich_label_name(_load_value)

#endregion
################################################################################











