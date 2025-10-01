@tool
class_name SMPFilesystemDir
extends Node


""" class """
var __c: SMPClassManagers
var _find_popup_panel: SMPFindPopupPanel
var _find_script: SMPFindScript


var _sc_path_arr: Array[String]

var _root_folder_names: Array[String]:
	set(_value):
		_root_folder_names = _value
	get:
		return _root_folder_names

var _store_setup_arr: Array:
	set(_value):
		_store_setup_arr = _value

var _editor_filesystem: EditorFileSystemDirectory:
	set(_value):
		_editor_filesystem = _value

var _is_load_button: bool = false


################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	_store_setup_arr = _setup_arr

	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item
			elif item is SMPFindPopupPanel:
				_find_popup_panel = item
			elif item is SMPFindScript:
				_find_script = item

#endregion
################################################################################
#region _sort_names

func _sort_custom_path(_a: String, _b: String) -> bool:
	return _a.get_file() < _b.get_file()

#endregion
################################################################################
#region _set_folders

func _set_file_subdir_init() -> void:
	_root_folder_names = _find_popup_panel._get_folder_names()
	var _count: int = _editor_filesystem.get_subdir_count()

	_sc_path_arr.clear()

	for i: int in range(_count):
		var _folder := _editor_filesystem.get_subdir(i)
		var _folder_name: String = _editor_filesystem.get_subdir(i).get_name()

		if _root_folder_names.has(_folder_name):
			_find_file_subdir(_folder)

	_sc_path_arr.sort_custom(_sort_custom_path)

	_spawn_instance_script_button(_sc_path_arr)
	_find_script._get_words_from_script(_sc_path_arr)
	#print("sc_path_arr; ", _sc_path_arr.size())

	if _find_popup_panel._store_row_size == -1:
		_find_popup_panel._get_column_equal_size(_sc_path_arr)

#endregion
################################################################################
#region _find_gd_scripts

func _find_file_subdir(folder: EditorFileSystemDirectory) -> void:
	if folder == null:
		return

	for i: int in range(folder.get_file_count()):
		var _file_name: String = folder.get_file(i)

		if _file_name.ends_with(".gd"):
			var _file_path: String = folder.get_file_path(i)
			if not _sc_path_arr.has(_file_path):
				_sc_path_arr.push_back(_file_path)

	for i: int in range(folder.get_subdir_count()):
		var _sub_folder := folder.get_subdir(i)
		_find_file_subdir(_sub_folder)

#endregion
################################################################################
#region _ins_script_button

func _spawn_instance_script_button(_sc_path_arr: Array[String]) -> void:
	var _index: int = 0
	var _num: int = 0
	var _movable_count: int = __c._setup_settings._finder_script_row_min_size
	var _processed: int = 0

	var _equal_size: int = _find_popup_panel._get_column_equal_size(_sc_path_arr)
	var _set_max_column: int = __c._setup_project._get_popup_find_column_size()
	var _result_quanty: int = _movable_count * _set_max_column

	_is_load_button = true

	for _path: String in _sc_path_arr:
		_movable_count = _movable_count if _sc_path_arr.size() < _result_quanty else _equal_size

		if _index > 0 and _index % _movable_count == 0:
			_num += 1

		var _name_scene: SMPButtonScript = __c._setup_settings._scene_popup_res["button_script"].instantiate()
		_find_popup_panel._script_containers[_num]._set_add_child_script(_name_scene)
		_name_scene._setup_class(_store_setup_arr)
		_name_scene._set_instance_status(_path)
		_index += 1

		_processed += 1
		if _processed % 150 == 0:
			await get_tree().process_frame

			if not _find_popup_panel.is_visible():
				_find_popup_panel._set_panel_hide()
				return

	_find_popup_panel._set_name_button_icon_color()
	_find_popup_panel._label_script_size._set_label_name(_sc_path_arr.size())
	_is_load_button = false

	if _find_script._store_text != "":
		_find_popup_panel._line_edit_find.text_changed.emit(_find_script._store_text)
	_has_selected_folder()

#endregion
################################################################################
#region _focus_selected_folder

func _has_selected_folder() -> void:
	if _find_popup_panel._current_folder_dict["index"] != -1:
		var _select_folder: String = _find_popup_panel._current_folder_dict["name"]
		var _folder_container := _find_popup_panel._folder_container
		await get_tree().process_frame

		for child: SMPButtonFolder in _folder_container._item_container.get_children():
			if child._store_name == _select_folder:
				child._folder_button.grab_focus()
				child._set_visible_focus_panel(true)
				_find_popup_panel._folder_container._get_file_subdir_select(child)
				_find_popup_panel._set_line_edit_status("all")
				return

#endregion
################################################################################

