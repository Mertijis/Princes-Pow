@tool
class_name SMPSaveLoadHandler
extends Resource


""" class """
var __c: SMPClassManagers
var _dock_main: ScriptMultiPlusDock


################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is ScriptMultiPlusDock:
				_dock_main = item
			elif item is SMPClassManagers:
				__c = item

#endregion
################################################################################
#region _load_split_container_process

func _loading_container_data_handler(_load_data: Dictionary, _key_index: String) -> void:
	if __c._godot_conf.has_section_key(__c._setup_settings._section, _key_index):
		var _key_int: int = _key_index.to_int()

		for key in _load_data[_key_int]:
			var _load_value: Variant = _load_data[_key_int][key]

			var _dock_split_1 := _dock_main._dock_split
			var _dock_split_2 := _dock_main._dock_split2

			match key:
				"dock_split_1V":
					if _dock_split_1.vertical:
						_dock_split_1.split_offset = _load_value
				"dock_split_1H":
					if not _dock_split_1.vertical:
						_dock_split_1.split_offset = _load_value

				"dock_split_2V":
					if _dock_split_2.vertical:
						_dock_split_2.split_offset = _load_value
				"dock_split_2H":
					if not _dock_split_2.vertical:
						_dock_split_2.split_offset = _load_value

#endregion
################################################################################






