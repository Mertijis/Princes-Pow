@tool
class_name SMPSaveLoadConf
extends Resource


""" class """
var __c: SMPClassManagers
var _plugin: ScriptMultiPlusPlugin
var _dock_main: ScriptMultiPlusDock
var _debug_manager: SMPDebugManager

var _timer_saved_cont: SMPTimerUtility
var _timer_saved_recent: SMPTimerUtility

var _save_key: Dictionary:
	set(_value):
		_save_key = _value
	get:
		return _save_key

var _is_saving_cont: bool = false
var _is_saving_recent: bool = false

""" save_data """
var _store_data0: Dictionary[int, Dictionary]
var _store_data1: Dictionary[int, Dictionary]
var _store_data2: Dictionary[int, Dictionary]
var _store_data3: Dictionary[int, Dictionary]

var _store_data_recent1: Dictionary[int, Dictionary]
var _store_data_recent2: Dictionary[int, Dictionary]
var _store_data_recent3: Dictionary[int, Dictionary]


var _indexs: Array[String] = ["index_0", "index_1", "index_2", "index_3"]
var _recent_keys: Array[String] = ["recent_1", "recent_2", "recent_3"]
var _recent_indexs: Array[String] = ["recent_select_1", "recent_select_2", "recent_select_3"]


##:: setup
################################################################################
#region _set_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item
			elif item is ScriptMultiPlusPlugin:
				_plugin = item
			elif item is ScriptMultiPlusDock:
				_dock_main = item
			elif item is SMPDebugManager:
				_debug_manager = item

	_timer_saved_cont = SMPTimerUtility.new(_dock_main)
	_timer_saved_recent = SMPTimerUtility.new(_dock_main)

#endregion
################################################################################
#region _timer

func _set_is_saving_cont(_active: bool) -> void:
	_is_saving_cont = _active

func _set_is_saving_recent(_active: bool) -> void:
	_is_saving_recent = _active

func _on_timer_saving_cont() -> void:
	_timer_saved_cont._init_timeout_auto()
	_set_is_saving_cont(false)

func _on_timer_saving_recent() -> void:
	_timer_saved_recent._init_timeout_auto()
	_set_is_saving_recent(false)

#endregion
################################################################################


##:: data_utility
################################################################################
#region save_data_get

func _get_save_data(_idx: String) -> Dictionary:
	var _section: String = __c._setup_settings._section
	if __c._godot_conf.has_section(_section):
		if __c._godot_conf.has_section_key(_section, _idx):
			var _load_data: Dictionary = __c._godot_conf.get_value(_section, _idx)
			return _load_data
	return {}

func _get_save_data_index(_cont_index: int) -> Dictionary:
	var _section: String = __c._setup_settings._section
	if __c._godot_conf.has_section(_section):
		for idx: String in _indexs:
			if idx == "index_0":
				continue
			if __c._godot_conf.has_section_key(_section, idx):
				var _key_int: int = idx.to_int()
				if _key_int != _cont_index:
					continue
				var _load_data: Dictionary = __c._godot_conf.get_value(_section, idx)
				return _load_data
	return {}

func _get_save_data_recent_index(_container_index: int) -> Dictionary:
	var _section: String = __c._setup_settings._section
	for key: String in _recent_keys:
		var _key_int: int = key.to_int()
		if not __c._godot_conf.has_section_key(_section, key):
			continue

		if _key_int == _container_index:
			var _recent_data: Dictionary = __c._godot_conf.get_value(_section, key)
			return _recent_data
	return {}

#endregion
################################################################################
#region save_data_rebuild

func _set_save_data_rebuild() -> void:
	for idx: String in _indexs:
		var _key_int: int = idx.to_int()
		if _key_int == 0:
			continue

		var _data: Dictionary = _get_save_data(idx)
		var _count: int = 0

		if _dock_main._script_item_list.item_count > 0:
			_count = _dock_main._script_item_list.item_count
		for key: int in _data:
			var _sc_names: Array = _data[key].get("sc_name", [])

			if _sc_names.is_empty():
				continue

			for i: int in range(_count):
				if __c._saveload_filesystem._script_check_list_extension(i):
					var _name: String = _dock_main._script_item_list.get_item_text(i)
					if _name == _sc_names[1]:
						var _scte := _dock_main._get_focus_scte_dict(key)
						_scte["tab_index"] = i
						_data[key]["tab_index"] = i
						_save_parameter(key, _data[key])

#endregion
################################################################################
#region clear_data_indexs

func _clear_data_index(_data_index: int) -> void:
	if __c._godot_conf.has_section(__c._setup_settings._section):
		for idx: String in _indexs:
			if __c._godot_conf.has_section_key(__c._setup_settings._section, idx):
				var _key_int: int = idx.to_int()
				if _key_int == _data_index:
					__c._godot_conf.erase_section_key(__c._setup_settings._section, idx)
					__c._godot_conf.save(__c._setup_settings._conf_path)
					return

func _clear_data_containers(_log: String = "log") -> void:
	if __c._godot_conf.has_section(__c._setup_settings._section):
		for idx: String in _indexs:
			if idx == "index_0":
				if _log == "all":
					if __c._godot_conf.has_section_key(__c._setup_settings._section, idx):
						__c._godot_conf.erase_section_key(__c._setup_settings._section, idx)
						break
				continue
			if __c._godot_conf.has_section_key(__c._setup_settings._section, idx):
				__c._godot_conf.erase_section_key(__c._setup_settings._section, idx)
				if _log != "":
					push_warning("Deleted container data: %s" % idx)
			else:
				if _log != "":
					push_warning("Not exist container data: %s" % idx)
		__c._godot_conf.save(__c._setup_settings._conf_path)

#endregion
################################################################################


##:: saveload
################################################################################
#region _save_param

func _save_parameter_type_value(_self_index: int, _save_key: String, _value: Variant) -> void:
	var _data: Dictionary[int, Dictionary] = {
		_self_index: {_save_key: _value}
	}
	_save_data_struct(_data)

func _save_parameter(_self_index: int, _box_data: Dictionary) -> void:
	var _dict := _save_key
	var _data: Dictionary[int, Dictionary] = {
		_self_index: {
			_dict["f_index"]: _box_data.get("focus_index", -1),
			_dict["t_index"]: _box_data.get("tab_index", -1),
			_dict["s_name"]: _box_data.get("sc_name", []),
			_dict["sc_path"]: _box_data.get("script_path", ""),
			_dict["suid_path"]: _box_data.get("uid_path", ""),
		}
	}
	_save_data_struct(_data)

#endregion
################################################################################
#region cont_data_save

func _save_data_struct(_data_values: Dictionary) -> void:
	#print("data: ", _data_values)

	for idx: String in _indexs:
		var _key_int: int = idx.to_int()

		for key: int in _data_values:
			if key == _key_int:
				if not __c._godot_conf.has_section_key(__c._setup_settings._section, idx):
					__c._godot_conf.set_value(__c._setup_settings._section, idx, _data_values)

					match _key_int:
						0:
							_store_data0 = _data_values
						1:
							_store_data1 = _data_values
						2:
							_store_data2 = _data_values
						3:
							_store_data3 = _data_values
				else:
					match key:
						0:
							_store_data0[key].merge(_data_values[key], true)
							__c._godot_conf.set_value(__c._setup_settings._section, idx, _store_data0)
						1:
							_store_data1[key].merge(_data_values[key], true)
							__c._godot_conf.set_value(__c._setup_settings._section, idx, _store_data1)
						2:
							_store_data2[key].merge(_data_values[key], true)
							__c._godot_conf.set_value(__c._setup_settings._section, idx, _store_data2)
						3:
							_store_data3[key].merge(_data_values[key], true)
							__c._godot_conf.set_value(__c._setup_settings._section, idx, _store_data3)

	__c._godot_conf.save(__c._setup_settings._conf_path)
	if not _is_saving_cont:
		_set_is_saving_cont(true)
		__debug_save_data_log("214")
		_timer_saved_cont._set_timer_start_auto(0.2, 1, 1, _on_timer_saving_cont)
	#print("saved_config")

#endregion
################################################################################
#region cont_data_load

func _loading_data() -> void:
	if __c._godot_conf.has_section(__c._setup_settings._section):
		var _store_path_arr: Array[String] = []

		for idx: String in _indexs:
			if __c._godot_conf.has_section_key(__c._setup_settings._section, idx):
				var _load_data: Dictionary = __c._godot_conf.get_value(__c._setup_settings._section, idx)
				var _key_int: int = idx.to_int()

				var _bar_items: Array
				var _path: String = ""
				var _index_data: Dictionary = _load_data.get(_key_int, null)

				_path = _index_data.get("uid_path", "")

				if _path == "":
					_path = _index_data.get("script_path", "")
				if _path != "":
					_store_path_arr.push_back(_path)

				_dock_main._store_load_data.merge(_load_data)

				match _key_int:
					0:
						_store_data0 = _load_data
					1:
						_store_data1 = _load_data
						_bar_items = _dock_main._mcontainer_1._dock_item_bar._get_item_arr()
					2:
						_store_data2 = _load_data
						_bar_items = _dock_main._mcontainer_2._dock_item_bar._get_item_arr()
					3:
						_store_data3 = _load_data
						_bar_items = _dock_main._mcontainer_3._dock_item_bar._get_item_arr()

		_store_path_arr.append_array(_loading_recent_path_data())
		_dock_main._store_load_path.append_array(_store_path_arr)
		#prints("path_arr: ", _store_path_arr, _dock_main._store_load_data)

#endregion
################################################################################
#region recent_path_data_load

func _loading_recent_path_data() -> Array[String]:
	var _section: String = __c._setup_settings._section

	if not __c._godot_conf.has_section(__c._setup_settings._section):
		return []
	var _store_path_arr: Array[String] = []

	for idx: String in _recent_keys:
		if __c._godot_conf.has_section_key(_section, idx):
			var _load_data: Dictionary = __c._godot_conf.get_value(_section, idx)
			var _path: String = ""

			for key: int in _load_data:
				var _index_data: Dictionary = _load_data.get(key, {})

				if _index_data.is_empty():
					continue
				_path = _index_data.get("uid_path", "")

				if _path == "":
					_path = _index_data.get("script_path", "")

				if _path != "":
					_store_path_arr.push_back(_path)

	return _store_path_arr

#endregion
################################################################################


##:: lazy
################################################################################
#region _lazy_load

func _lazy_loading_data() -> Array:
	if __c._godot_conf.has_section(__c._setup_settings._section):
		var idx: String = _indexs[0]
		if __c._godot_conf.has_section_key(__c._setup_settings._section, idx):
			var _load_data: Dictionary = __c._godot_conf.get_value(__c._setup_settings._section, idx)
			return [_load_data, idx]
	return []

#endregion
################################################################################
#region _lazy_load_item_bar

func _loading_data_lazy() -> void:
	if __c._godot_conf.has_section(__c._setup_settings._section):
		var _store_path_arr: Array[String] = []

		for idx: String in _indexs:
			if __c._godot_conf.has_section_key(__c._setup_settings._section, idx):
				var _load_data: Dictionary = __c._godot_conf.get_value(__c._setup_settings._section, idx)
				var _key_int: int = idx.to_int()

				var _bar_items: Array

				match _key_int:
					1:
						_bar_items = _dock_main._mcontainer_1._dock_item_bar._get_item_arr()
					2:
						_bar_items = _dock_main._mcontainer_2._dock_item_bar._get_item_arr()
					3:
						_bar_items = _dock_main._mcontainer_3._dock_item_bar._get_item_arr()

				if _key_int > 0:
					for item in _bar_items:
						if item.has_method("_loading_buttons_data"):
							item._loading_buttons_data(_load_data, idx)

#endregion
################################################################################


##:: recent
################################################################################
#region recent_data_save

func _save_data_struct_recent(
	_data_values: Dictionary, _curr_index: int, _container_index: int, _type: String
	) -> void:
	#print("data: ", _data_values)
	if _curr_index == -1:
		return

	var _store_data_select: Dictionary
	var _temp: Dictionary[int, Dictionary] = {}
	var _section: String = __c._setup_settings._section

	match _container_index:
		1:
			_store_data_select = _store_data_recent1
		2:
			_store_data_select = _store_data_recent2
		3:
			_store_data_select = _store_data_recent3

	for key: String in _recent_keys:
		var _key_int: int = key.to_int()

		if _key_int == _container_index:
			match _type:
				"add":
					if not __c._godot_conf.has_section_key(_section, key):
						__c._godot_conf.set_value(_section, key, _data_values)
						if not _store_data_select.has(_curr_index):
							_store_data_select[_curr_index] = _data_values[_curr_index]
					else:
						if not _store_data_select.has(_curr_index):
							_store_data_select[_curr_index] = {}

					if _store_data_select.has(_curr_index):
						_store_data_select[_curr_index].merge(_data_values[_curr_index])
						__c._godot_conf.set_value(_section, key, _store_data_select)
						__c._godot_conf.save(__c._setup_settings._conf_path)

				"rebuild":
					_temp = _convert_type(_data_values.duplicate())

					match _container_index:
						1:
							_store_data_recent1 = _temp
						2:
							_store_data_recent2 = _temp
						3:
							_store_data_recent3 = _temp

					__c._godot_conf.set_value(_section, key, _temp)
					__c._godot_conf.save(__c._setup_settings._conf_path)
	if not _is_saving_recent:
		_set_is_saving_recent(true)
		__debug_save_data_recent_log("393")
		_timer_saved_recent._set_timer_start_auto(0.22, 1, 1, _on_timer_saving_recent)

func _save_data_menu_index(_data_values: Dictionary, _container_index: int) -> void:
	var _section: String = __c._setup_settings._section
	for key: String in _recent_indexs:
		var _key_int: int = key.to_int()
		if _key_int == _container_index:
			if not __c._godot_conf.has_section_key(_section, key):
				__c._godot_conf.set_value(_section, key, _data_values)
			else:
				__c._godot_conf.set_value(_section, key, _data_values)
			__c._godot_conf.save(__c._setup_settings._conf_path)

func _convert_type(_dict: Dictionary) -> Dictionary[int, Dictionary]:
	var _temp: Dictionary[int, Dictionary] = {}
	for k: int in _dict:
		if typeof(k) == TYPE_INT and typeof(_dict[k]) == TYPE_DICTIONARY:
			_temp[k] = _dict[k]
	return _temp

#endregion
################################################################################
#region recent_data_load

func _load_data_recent(_container_index: int) -> Dictionary:
	var _section: String = __c._setup_settings._section
	for key: String in _recent_keys:
		var _key_int: int = key.to_int()
		if not __c._godot_conf.has_section_key(_section, key):
			continue

		if _key_int == _container_index:
			var _recent_data: Dictionary = __c._godot_conf.get_value(_section, key)
			match _container_index:
				1:
					_store_data_recent1 = _recent_data
				2:
					_store_data_recent2 = _recent_data
				3:
					_store_data_recent3 = _recent_data
			return _recent_data
	return {}

func _load_data_menu_index(_container_index: int) -> Dictionary:
	var _section: String = __c._setup_settings._section
	for key: String in _recent_indexs:
		var _key_int: int = key.to_int()
		if _key_int == _container_index:
			if not __c._godot_conf.has_section_key(_section, key):
				continue
			var _menu_index: Dictionary = __c._godot_conf.get_value(_section, key)
			return _menu_index
	return {}

#endregion
################################################################################
#region recent_data_clear

func _clear_data_recent(_container_index: int) -> void:
	var _section: String = __c._setup_settings._section

	for key: String in _recent_keys:
		var _key_int: int = key.to_int()

		if _key_int == _container_index:
			if __c._godot_conf.has_section_key(_section, key):
				match _container_index:
					1:
						_store_data_recent1.clear()
						__c._godot_conf.erase_section_key(_section, _recent_indexs[0])
					2:
						_store_data_recent2.clear()
						__c._godot_conf.erase_section_key(_section, _recent_indexs[1])
					3:
						_store_data_recent3.clear()
						__c._godot_conf.erase_section_key(_section, _recent_indexs[2])
				__c._godot_conf.erase_section_key(_section, key)
				__c._godot_conf.save(__c._setup_settings._conf_path)
			return

#endregion
################################################################################
#region has_dock_split_data

func _has_check_index_data(_key_index: String) -> bool:
	if __c._godot_conf.has_section_key(__c._setup_settings._section, _key_index):
		return true
	return false

#endregion
################################################################################


##:: debug
################################################################################
#region _debun_cont_save_data

func __debug_save_data_log(_line: String) -> void:
	if _debug_manager == null or not _debug_manager._save_data_log:
		return
	var _cl_name: String = "SMPSaveLoadConf"

	for idx: String in _indexs:
		if idx == "index_0":
			var _data: Dictionary = _get_save_data(idx)
			var _notif: Array = _debug_manager._dock_split_data_notif(_data[0])
			_debug_manager._save_data_debug_log(
				"rich", self, _cl_name, "saved_data_0", _notif, _line
				)
			continue

		var _key_int: int = idx.to_int()
		var _data: Dictionary = _get_save_data(idx)

		if not _data.is_empty():
			var _notif: Array = _debug_manager._saving_data_notif(_data[_key_int])
			_debug_manager._save_data_debug_log(
				"rich", self, _cl_name,
				"saved_data_%s" % _key_int, _notif, _line,
				)

#endregion
################################################################################
#region _debug_recent_save_data

func __debug_save_data_recent_log(_line: String) -> void:
	if not _debug_manager._save_data_log:
		return
	var _cl_name: String = "SMPSaveLoadConf"

	for idx: String in _recent_indexs:
		var _key_int: int = idx.to_int()
		var _data: Dictionary = _get_save_data_recent_index(_key_int)

		if not _data.is_empty():
			for i: int in _data.keys():
				var _notif: Array = _debug_manager._loading_data_notif(_data[i])
				_debug_manager._save_data_debug_log(
					"rich", self, _cl_name,
					"saved_data_recent_%s[%s]" % [_key_int, i], _notif, _line,
					)

#endregion
################################################################################

