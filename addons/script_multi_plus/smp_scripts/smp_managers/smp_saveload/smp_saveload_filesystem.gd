@tool
class_name SMPFileSystem
extends Resource


""" class """
var __c: SMPClassManagers
var _debug_manager: SMPDebugManager
var _plugin: ScriptMultiPlusPlugin
var _dock_main: ScriptMultiPlusDock

var _script_item_list: ItemList
var _code_edit_arr: Array[CodeEdit]
var _file_removed_item_dict: Dictionary[String, int]

var _cl_name: String
var _log_exs: String

var __end: String = "[/color]"
var __icolor: String = "[color=orange]"
var __tcolor: String = "[color=deep_pink]"
var __bcolor: String = "[color=medium_orchid]"
var __scolor: String = "[color=khaki]"
var __ncolor: String = "[color=pale_green]"


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
			elif item is SMPDebugManager:
				_debug_manager = item
			elif item is ItemList:
				_script_item_list = item

	_setup_log_err()
	_init_item_dict()

func _setup_log_err() -> void:
	_cl_name = __c._setup_settings._err_text["cl_name"]
	_log_exs = __c._setup_settings._err_text["log_exs"]

func _init_item_dict() -> void:
	var _rkeys := __c._saveload_conf._recent_keys
	for key: String in _rkeys:
		_file_removed_item_dict[key] = -1

#endregion
################################################################################


##:: filesystem
################################################################################
#region fs_emit_util
## not use
func _emit_popup_close_id() -> void:
	var _popup: PopupMenu = _get_script_menu_bar_popup_id()[0]
	var _close_id: int = _get_script_menu_bar_popup_id()[1]
	_popup.id_pressed.emit(_close_id)

## not use
func _get_script_menu_bar_popup_id() -> Array:
	var _menu_bar := _plugin._script_menu_button
	var _popup: PopupMenu = _menu_bar.get_popup()
	for idx: int in range(_popup.item_count):
		var _id: int = _popup.get_item_id(idx)
		var _title: String = _popup.get_item_text(idx)
		if _title == "Close":
			return [_popup, _id]
	return []

#endregion
################################################################################
#region fs_get_util

func _get_script_load(_path: String) -> GDScript:
	if _path == "":
		return null
	var _res := ResourceLoader.load(_path, "", ResourceLoader.CACHE_MODE_REPLACE)

	if _res == null:
		push_warning("Failed to load script at: %s" % _path)
		return null

	if _res is not GDScript:
		push_warning("Loaded resource is not a GDScript: %s" % _res)
		return null

	return _res as GDScript

#endregion
################################################################################
#region fs_UID_util

func _get_uid_path(_path: String) -> String:
	var _uid_num: int = ResourceLoader.get_resource_uid(_path)
	var _uid_path: String = ResourceUID.id_to_text(_uid_num)
	#print("uid: ", _uid_path)
	return _uid_path

func _get_uid_to_resource_path(_uid_path: String) -> String:
	var _uid_num: int = ResourceUID.text_to_id(_uid_path)
	var _res_path: String = ResourceUID.get_id_path(_uid_num)
	#print("res_path: ", _res_path)
	return _res_path

func _get_has_uid(_uid_path: String) -> bool:
	var _uid_num: int = ResourceUID.text_to_id(_uid_path)
	if ResourceUID.has_id(_uid_num):
		return true
	return false

func _has_check_script_path(_path: String) -> String:
	var _sc_path: String
	if _path != "":
		if _get_has_uid(_path):
			var _res_name: String = _get_uid_to_resource_path(_path)
			_sc_path = _res_name.get_file()
		else:
			_sc_path = _path.get_file()
	return _sc_path

func _convert_script_path(_path: String) -> Array[String]:
	var _sc_path: String
	var _uid_path: String

	if _path != "":
		if _get_has_uid(_path):
			var _res_name: String = _get_uid_to_resource_path(_path)
			_sc_path = _res_name.get_file()
			_uid_path = _path

	return [_uid_path, _sc_path]

#endregion
################################################################################
#region fs_has_check_util

func _script_check_list_extension(_index: int) -> bool:
	if _script_item_list.item_count > 0:
		var _list_name: String = _script_item_list.get_item_text(_index)
		if _list_name.get_extension() == "gd(*)":
			return true
		if _list_name.get_extension() == "gd":
			return true
		if _list_name.get_extension() == "txt":
			return true
	return false

func _check_same_saved_script_data(_dict: Dictionary) -> bool:
	if _script_item_list.item_count > 0:
		var _count: int = _script_item_list.item_count
		for i: int in range(_count):
			if _script_check_list_extension(i):
				var _name: String = _script_item_list.get_item_text(i)
				var _sc_name: Array = _dict.get("sc_name", [])
				_name = _check_name_cut_extension(_name)

				if not _sc_name.is_empty():
					if _name == _sc_name[1]:
						if i == _dict.get("tab_index", -1):
							return true
						push_warning("Script index is incorrect: ", _name)
						return false
	return false

func _check_name_cut_extension(_name: String) -> String:
	var _split: PackedStringArray
	if _name.contains("(*)"):
		_split = _name.rsplit("(")
	if not _split.is_empty():
		_name = _split[0]
	return _name

#endregion
################################################################################


##:: update
################################################################################
#region update_utility

func _clear_removed_item_dict() -> void:
	_file_removed_item_dict.clear()

func _set_removed_table(_save_key: String, _id: int) -> Dictionary:
	_file_removed_item_dict[_save_key] = _id
	return _file_removed_item_dict

func _get_global_class_name(_path: String) -> String:
	var _load_sc := _get_script_load(_path)
	if _load_sc is not GDScript:
		return ""
	return _load_sc.get_global_name()

func _rebuild_files_store_data(
	_type: String, _irecent: SMPRecentMenuButton, _dict: Dictionary, _line: String,
	) -> void:
	_irecent._recent_data = _dict
	_irecent._refresh_file_process()
	match _type:
		"moved":
			_debug_moved_rebuild_data(_dict, _line)
		"removed":
			_debug_removed_rebuild_data(_dict, _line)

#endregion
################################################################################
#region update_recent_data

func _update_move_recent_data(_recent_data: Dictionary, _container_index: int) -> void:
	var _count: int = 0
	var _ilist: Dictionary = {}

	if _script_item_list.item_count > 0:
		_count = _script_item_list.item_count

	for i: int in range(_count):
		if _script_check_list_extension(i):
			var _name: String = _script_item_list.get_item_text(i)
			_ilist[_name] = i

	var _cont: SMPDockContainer = _dock_main._get_focus_mcontainer(_container_index)
	var _recent := _cont._get_recent_menu_item()

	if not _recent_data.is_empty():
	## changed_tab_index
		for ikey: int in _recent_data:
			var _dict: Dictionary = _recent_data[ikey]
			var _findex: int = _dict.get("focus_index", -1)
			var _sc_names: Array = _dict.get("sc_name", [])

			if _findex != _container_index:
				continue
			if _sc_names.is_empty():
				continue

			for key: String in _ilist:
				if key == _sc_names[1]:
					_recent_data[ikey]["tab_index"] = _ilist[key]

		_recent._recent_data = _recent_data
		_recent._saving_recent_data(_recent_data, "rebuild")

#endregion
################################################################################
#region update_move_script

func _update_move_script_list() -> void:
	_debug_save_update("save_updatte_pre", "258")

	var _slist: Dictionary = _get_script_list()
	var _containers: Array[SMPDockContainer] = _dock_main._get_mcontainer_arr()

	for cont: SMPDockContainer in _containers:
		var _scte: Dictionary = cont._scte_dict

		if not _scte.is_empty():
		## changed_tab_index
			var _sc_names: Array = _scte.get("sc_name", [])
			var _findex: int = _scte.get("focus_index", -1)

			if not is_instance_valid(_scte.get("root", null)):
				__c._saveload_conf._clear_data_index(cont.container_index)
				_scte.clear()
			else:
				var _root: Node = _scte.get("root", null)
				for key: String in _slist:
					if _findex != -1:
						if not _sc_names.is_empty():
							if key == _sc_names[1]:
								_scte["tab_index"] = _slist[key]

			## saving
				#if _root != null and _root.is_class(&"EditorHelp"):
					#continue
				#if _root != null and _root.is_class(&"TextEditor"):
					#continue

				if _findex != -1:
					_scte["focus_index"] = cont.container_index
					cont._set_rich_text_item(_sc_names)
					__c._saveload_conf._save_parameter(cont.container_index, _scte)

	_debug_save_update("save_update_post", "291")

#endregion
################################################################################
#region files_moved

func _handle_files_moved(
	_old_file: String, _new_file: String, _section_keys: Array[String], _button_index: int
	) -> void:
	var _section: String = __c._setup_settings._section
	var _cname := _get_global_class_name(_old_file)

	for save_key: String in _section_keys:
		var _sindex: int = save_key.to_int()

		if save_key == "index_0":
			continue
		if _button_index != -1:
			if _sindex != _button_index:
				continue

		if __c._godot_conf.has_section_key(_section, save_key):
			var _temp: Dictionary[int, Dictionary] = {}
			var _data: Dictionary = __c._godot_conf.get_value(_section, save_key)
			var _mcont := _dock_main._get_focus_mcontainer(_sindex)

			for key_int: int in _data:
				var _path: String = _data[key_int].get("script_path", "")
				if _path == "":
					continue

				if _old_file == _path:
					_data[key_int]["script_path"] = _new_file
					_data[key_int]["sc_name"][1] = _new_file.get_file()

					if _cname != "":
						_data[key_int]["sc_name"][0] = _cname
					else:
						_data[key_int]["sc_name"][0] = ""
					_mcont._scte_dict["script_path"] = _new_file

				_temp.merge(_data, true)

			if not _temp.is_empty():
				__c._godot_conf.set_value(_section, save_key, _temp)

			match save_key:
				"recent_1":
					var _item_recent := _mcont._get_recent_menu_item()
					__c._saveload_conf._store_data_recent1 = _temp
					_rebuild_files_store_data("moved",
						_item_recent, __c._saveload_conf._store_data_recent1, "342"
						)
				"recent_2":
					var _item_recent := _mcont._get_recent_menu_item()
					__c._saveload_conf._store_data_recent2 = _temp
					_rebuild_files_store_data("moved",
						_item_recent, __c._saveload_conf._store_data_recent2, "348"
						)
				"recent_3":
					var _item_recent := _mcont._get_recent_menu_item()
					__c._saveload_conf._store_data_recent3 = _temp
					_rebuild_files_store_data("moved",
						_item_recent, __c._saveload_conf._store_data_recent3, "354"
						)
	__c._godot_conf.save(__c._setup_settings._conf_path)

#endregion
################################################################################
#region file_removed

func _handle_file_removed(
	_remove_file: String, _section_keys: Array[String], _button_index: int
	) -> void:
	var _section: String = __c._setup_settings._section

	for save_key: String in _section_keys:
		var _sindex: int = save_key.to_int()
		var _rindex: int = 2

		if save_key == "index_0":
			continue

		if _button_index != -1:
			if _sindex != _button_index:
				continue
		else:
			if save_key.begins_with("index"):
				var _mcont := _dock_main._get_focus_mcontainer(_sindex)
				var _sc_path: String = _mcont._scte_dict.get("script_path", "")
				if _remove_file == _sc_path:
					for child in _mcont._get_vbox_children():
						child.queue_free()
					_mcont._scte_dict.clear()
					__c._saveload_conf._clear_data_index(_mcont.container_index)

		if __c._godot_conf.has_section_key(_section, save_key):
			var _temp: Dictionary[int, Dictionary]
			var _data: Dictionary = __c._godot_conf.get_value(_section, save_key)
			var _mcont := _dock_main._get_focus_mcontainer(_sindex)

			for key_int: int in _data.keys():
				var _path: String = _data[key_int].get("script_path", "")
				if _path == "":
					continue
				if _remove_file == _path:
					_data.erase(key_int)
					_set_removed_table(save_key, key_int)
					_log_file_removed(save_key, key_int, _remove_file, "399")
					break

			if not _data.is_empty():
				for key: int in _data:
					if not _temp.has(_rindex):
						_temp[_rindex] = {}
					_temp[_rindex] = _data[key]
					_rindex += 1

			__c._godot_conf.set_value(_section, save_key, _temp)

			if not _temp.is_empty():
				match  save_key:
					"recent_1":
						var _item_recent := _mcont._get_recent_menu_item()
						__c._saveload_conf._store_data_recent1 = _temp
						_rebuild_files_store_data("removed",
							_item_recent, __c._saveload_conf._store_data_recent1, "417"
							)
					"recent_2":
						var _item_recent := _mcont._get_recent_menu_item()
						__c._saveload_conf._store_data_recent2 = _temp
						_rebuild_files_store_data("removed",
							_item_recent, __c._saveload_conf._store_data_recent2, "423"
							)
					"recent_3":
						var _item_recent := _mcont._get_recent_menu_item()
						__c._saveload_conf._store_data_recent3 = _temp
						_rebuild_files_store_data("removed",
							_item_recent, __c._saveload_conf._store_data_recent3, "429"
							)
	__c._godot_conf.save(__c._setup_settings._conf_path)

#endregion
################################################################################


##:: load
################################################################################
#region loaded_tab_change

func _load_select_tab_changed() -> void:
	if not _dock_main._store_load_path.is_empty():
		for path: String in _dock_main._store_load_path:
			if path != "":
				_script_load_select(path)

func _script_load_select(_sc_path: String) -> void:
	var _sc_name: String
	var _remove_num: int

	var _load_tab_num: int
	var _sel_item_num: int
	var _sel_item_text: String

	var _tabbar := _plugin._tab_container.get_tab_bar()
	var _tab_container := _plugin._tab_container
	var _current_tab: int = _tabbar.current_tab

	if _script_item_list.item_count > 0:
		_sc_name = _has_check_script_path(_sc_path)
		var _count: int = _script_item_list.item_count

		if _sc_name == "":
			_debug_manager._load_enabled_debug_log(
				"err", self, _cl_name, _log_exs, _sc_name, "465"
				)
			return

		if not _script_item_list.get_selected_items().is_empty():
			_sel_item_num = _script_item_list.get_selected_items()[0]
			_sel_item_text = _script_item_list.get_item_text(_sel_item_num)

		for i: int in range(_count):
			if _script_check_list_extension(i):
				var _name: String = _script_item_list.get_item_text(i)
				if _name == _sc_name:
					_load_tab_num = i
					_tabbar.current_tab = _load_tab_num
					_store_code_edits(_tab_container, i)
					continue

		var __notif := _debug_manager._boot_notif(
			_sel_item_num, _sel_item_text, _load_tab_num, _sc_name
			)
		_debug_load_enabled(__notif, "485")

#endregion
################################################################################
#region loaded_enable

func _load_enable_pressed() -> void:
	var _count: int = 0
	var _load_tab_num: int
	var _load_once: bool = false
	var _sc_name_dict: Dictionary

	var _tabbar := _plugin._tab_container.get_tab_bar()
	var _tab_container := _plugin._tab_container
	var _current_tab: int = _tabbar.current_tab

	var _load_data: Dictionary = _dock_main._store_load_data

## load_store_sc_names
	for key: int in _load_data:
		var _sc_names: Array = _load_data[key].get("sc_name", [])

		if key == 0 or _sc_names.is_empty():
			continue
		_sc_name_dict[_sc_names[1]] = _sc_names

	if _script_item_list.item_count > 0:
		_count = _script_item_list.item_count

## load_select_tabs
	for i: int in range(_count):
		if _script_check_list_extension(i):
			var _name: String = _script_item_list.get_item_text(i)
			var _list_name: Array = _sc_name_dict.get(_name, [])
			if not _list_name.is_empty():
				_load_tab_num = i
				_tabbar.current_tab = _load_tab_num
				_store_code_edits(_tab_container, i)

				var __notif := _debug_manager._enabled_notif(_load_tab_num, _list_name)
				_debug_load_enabled(__notif, "525")

#endregion
################################################################################
#region load_rebuild_data_index

func _update_boot_rebuild_recent_data(_container_index: int) -> void:
	var _slist: Dictionary = _get_script_list()
	var _recent_data: Dictionary = __c._saveload_conf._get_save_data_recent_index(_container_index)

	if not _recent_data.is_empty():
	## changed_tab_index
		for ikey: int in _recent_data:
			var _dict: Dictionary = _recent_data[ikey]
			var _findex: int = _dict.get("focus_index", -1)
			var _sc_names: Array = _dict.get("sc_name", [])

			if _findex != _container_index:
				continue
			if _sc_names.is_empty():
				continue

			for key: String in _slist:
				if key == _sc_names[1]:
					_recent_data[ikey]["tab_index"] = _slist[key]

		__c._saveload_conf._save_data_struct_recent(
			_recent_data, _container_index, _container_index, "rebuild"
			)

func _update_boot_rebuild_container_data(_container_index: int) -> void:
	var _slist: Dictionary = _get_script_list()
	var _save_data: Dictionary = __c._saveload_conf._get_save_data_index(_container_index)

	if not _save_data.is_empty():
	## changed_tab_index
		for ikey: int in _save_data:
			var _dict: Dictionary = _save_data[ikey]
			var _findex: int = _dict.get("focus_index", -1)
			var _sc_names: Array = _dict.get("sc_name", [])

			if _findex != _container_index:
				continue
			if _sc_names.is_empty():
				continue

			for key: String in _slist:
				if key == _sc_names[1]:
					_save_data[ikey]["tab_index"] = _slist[key]
					break

		__c._saveload_conf._save_parameter(_container_index, _save_data[_container_index])

#endregion
################################################################################
#region load_process

func _load_move_new_parent() -> void:
	var _load_data: Dictionary = _dock_main._store_load_data
	for key_int: int in _load_data:
		if key_int != 0:
			var _findex: int = _load_data[key_int].get("focus_index", -1)
			var _tindex: int = _load_data[key_int].get("tab_index", -1)
			var _sc_names: Array = _load_data[key_int].get("sc_name", [])
			var _sc_path: String = _load_data[key_int].get("script_path", "")
			var _suid_path: String = _load_data[key_int].get("uid_path", "")
			var _container: SMPDockContainer = _dock_main._get_focus_mcontainer(_findex)

			var __notif := _debug_manager._loading_data_notif(_load_data[key_int])
			_debug_loading_data(__notif, "loading_data", "594")

			if _sc_path == "":
				_unload_else(_findex, _container, _sc_names)
				continue

			if _check_same_saved_script_data(_load_data[key_int]):
				_dock_main._store_focus_index = _findex
				_container._store_tab_index = _tindex
				_container._store_sc_names = _sc_names
				_container._store_script_path = _sc_path
				_container._store_script_path_uid = _suid_path
				if _tindex != -1:
					_container._change_to_slected_new_script(_tindex)

			else:
				_unload_else(_findex, _container, _sc_names)


func _store_code_edits(_t_con: TabContainer, _index: int) -> void:
	var _scte: ScriptEditorBase = _t_con.get_child(_index)
	var _code_edit: CodeEdit = __c._setup_utility._get_code_edit_from_base(_scte)
	if not _code_edit_arr.has(_code_edit):
		_code_edit_arr.push_back(_code_edit)
	#print("code_edit_arr: ", _code_edit_arr)

#endregion
################################################################################
#region load_utility

func _unload_else(_findex: int, _cont: SMPDockContainer, _sc_names: Array) -> void:
	_dock_main._set_boot_not_list(_cont)
	__c._saveload_conf._clear_data_index(_findex)
	__c._saveload_conf._save_data_menu_index({"menu_index": -1}, _findex)
	if not _sc_names.is_empty():
		_dock_main._setup_ready_status()
		push_warning("Script not found in the list.: %s" % [_sc_names])

func _get_script_list() -> Dictionary:
	var _count: int = 0
	var _slist: Dictionary = {}

	if _script_item_list.item_count > 0:
		_count = _script_item_list.item_count
	for i: int in range(_count):
		if _script_check_list_extension(i):
			var _name: String = _script_item_list.get_item_text(i)
			_slist[_name] = i

	return _slist

#endregion
################################################################################


##:: debug_func
################################################################################
#region debug_

func _debug_save_update(_type: String, _line: String) -> void:
	if not _debug_manager._save_update:
		return
	var _index: int = 0
	print("//")
	for dict in _dock_main._get_scte_arr():
		_index += 1
		print_rich("%s[%s__%s]%s" % [__tcolor, _type, _index, __end])
		var _notif: Array = _debug_manager._data_dict_arr_notif(dict)
		_debug_manager._save_update_log("rich", self, _cl_name, _type, _notif, _line)
	print("//")

func _debug_load_enabled(__notif: Array, _line: String) -> void:
	_debug_manager._load_enabled_debug_log(
		"rich", self, _cl_name, "load_select_tab", __notif, _line
		)

func _debug_loading_data(__notif: Array, _log: String, _line: String) -> void:
	_debug_manager._load_enabled_debug_log(
		"rich", self, _cl_name, _log, __notif, _line
		)

func _log_file_removed(_skey: String, _kint: int, _rfile: String, _line: String) -> void:
	if not _debug_manager._file_removed:
		return
	var __notif: Array = [
		"%s %s" % [_skey, _kint],
		"removed %s" % _rfile,
	]
	_debug_manager._debug_log_res("rich", self, _cl_name, "removed", __notif, _line)

#endregion
################################################################################
#region debug_files_moved

func _debug_files_moved(__notif: Array, _log: String, _line: String) -> void:
	_debug_manager._files_moved_debug_log(
		"rich", self, _cl_name, _log, __notif, _line
		)

func _debug_moved_rebuild_data(_data: Dictionary, _line: String) -> void:
	if not _debug_manager._files_moved:
		return
	for key_int in _data:
		var _title: String = "files_moved_recent_data_%s" % key_int
		var __notif := _debug_manager._loading_data_notif(_data[key_int])
		_debug_files_moved(__notif, _title, _line)

#endregion
################################################################################
#region debug_file_removed

func _debug_file_removed(__notif: Array, _log: String, _line: String) -> void:
	_debug_manager._file_removed_debug_log(
		"rich", self, _cl_name, _log, __notif, _line
		)

func _debug_removed_rebuild_data(_data: Dictionary, _line: String) -> void:
	if not _debug_manager._file_removed:
		return
	for key_int: int in _data:
		var _title: String = "file_removed_recent_data_%s" % key_int
		var __notif := _debug_manager._loading_data_notif(_data[key_int])
		_debug_file_removed(__notif, _title, _line)

#endregion
################################################################################


