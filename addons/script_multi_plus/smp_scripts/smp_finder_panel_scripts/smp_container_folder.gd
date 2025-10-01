@tool
class_name SMPContainerFolder
extends MarginContainer


""" class """
var __c: SMPClassManagers
var _find_popup_panel: SMPFindPopupPanel
var _editor_fs_dir: SMPFilesystemDir
var _find_script: SMPFindScript


var _sc_path_arr: Array[String]
var _temp_container := VBoxContainer.new()


var _tree_file_dock: Tree:
	set(_value):
		_tree_file_dock = _value

var _store_setup_arr: Array:
	set(_value):
		_store_setup_arr = _value

var _root_folder_names: Array[String]:
	set(_value):
		_root_folder_names = _value
	get:
		return _root_folder_names

var _editor_filesystem: EditorFileSystemDirectory:
	set(_value):
		_editor_filesystem = _value


var _is_load_button: bool = false

@onready var _item_container: VBoxContainer = %ItemContainer
@onready var _scroll_container: ScrollContainer = %SContainer


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
			elif item is SMPFilesystemDir:
				_editor_fs_dir = item
			elif item is SMPFindScript:
				_find_script = item
			elif item is Tree:
				_tree_file_dock = item

#endregion
################################################################################
#region _set_status

func _set_add_child_folder(_child: Node) -> void:
	_item_container.add_child(_child)

func _get_tree_root_res() -> TreeItem:
	var _tree_item: TreeItem = _tree_file_dock.get_root()
	var _count: int = _tree_item.get_child_count()
	for i in range(_count):
		var _folder_name: String = _tree_item.get_child(i).get_text(0)
		if _folder_name == "res://":
			return _tree_item.get_child(i)
	return null

func _clear_item_container_children() -> void:
	for child in _item_container.get_children():
		child.queue_free()

func _sort_custom_path(_a: String, _b: String) -> bool:
	return _a.get_file() < _b.get_file()

#endregion
################################################################################
#region handle_tree_folder

func _set_tree_items() -> void:
	var _tree_res: TreeItem = _get_tree_root_res()
	_spawn_tree_items(_tree_res)

func _spawn_tree_items(_tree_res: TreeItem) -> void:
	var _root_folder_names: Array[String] = _find_popup_panel._get_folder_names()
	var _root_folder: TreeItem
	var _index: int = 0

	for _item in _tree_res.get_children():
		if _root_folder_names.has(_item.get_text(0)):
			_root_folder = _item
			_set_instance_tree_item(_item, 0, _index)
			_index += 1

			for child in _root_folder.get_children():
				_set_instance_tree_item(child, 5, _index)
				_index += 1
				var _name: String = child.get_text(0)
				if _name.get_extension() != "":
					_index -= 1

func _set_instance_tree_item(_item: TreeItem, _left_space: int, _index: int) -> void:
	var _name: String = _item.get_text(0)
	var _color: Color = _item.get_icon_modulate(0)
	var _parent: String = _item.get_parent().get_text(0)

	match _parent:
		"res://":
			_parent = _item.get_metadata(0).rstrip("/")
		_:
			_parent = "res://%s" % _parent

	if _name.get_extension() == "":
		var _ins: SMPButtonFolder = __c._setup_settings._scene_popup_res["button_folder"].instantiate()
		var _scene_folder: SMPButtonFolder = _ins
		_set_add_child_folder(_scene_folder)
		#prints("index: ", _index, _name)

		_scene_folder._setup_class(_store_setup_arr)
		_scene_folder._set_instance_status(_name, _parent, _color, _left_space, _index)

#endregion
################################################################################
#region _get_select_folder

func _get_file_subdir_select(_select: SMPButtonFolder) -> void:
	_root_folder_names = _find_popup_panel._get_folder_names()
	var _count: int = _editor_filesystem.get_subdir_count()

	_sc_path_arr.clear()

	for i in range(_count):
		var _folder := _editor_filesystem.get_subdir(i)
		var _folder_name: String = _editor_filesystem.get_subdir(i).get_name()
		var _split := _select._store_parent.split("//")

		if _folder_name == _split[1]:
			if _root_folder_names.has(_folder_name):
				var _find_folder := _get_folder(_folder, _select._store_name)

				_find_file_subdir(_find_folder)
				break

	_sc_path_arr.sort_custom(_sort_custom_path)

	_set_find_pressed_folder(_sc_path_arr)
	_find_script._get_words_from_script(_sc_path_arr)
	_find_popup_panel._label_select_folder._set_data_labels(_select)

func _get_folder(_root_folder: EditorFileSystemDirectory, _select_folder: String) -> EditorFileSystemDirectory:
	if _root_folder.get_name() == _select_folder:
		return _root_folder

	var _index: int = _root_folder.find_dir_index(_select_folder)
	if _index == -1:
		push_warning("Not exist folder: %s" % _select_folder)
		return _root_folder

	return _root_folder.get_subdir(_index)

#endregion
################################################################################
#region _find_gd_scripts

func _find_file_subdir(folder: EditorFileSystemDirectory) -> void:
	if folder == null:
		return

	for i in range(folder.get_file_count()):
		var _file_name: String = folder.get_file(i)

		if _file_name.ends_with(".gd"):
			var _file_path: String = folder.get_file_path(i)
			if not _sc_path_arr.has(_file_path):
				_sc_path_arr.push_back(_file_path)

	for i in range(folder.get_subdir_count()):
		var _sub_folder := folder.get_subdir(i)
		_find_file_subdir(_sub_folder)

#endregion
################################################################################
#region _set_folder_pressed

func _set_find_pressed_folder(_sc_path_arr: Array[String]) -> void:
	var _index: int = 0
	var _num: int = 0
	var _movable_count: int = __c._setup_settings._finder_script_row_min_size
	var _processed: int = 0

	var _equal_size: int = _find_popup_panel._get_column_equal_size(_sc_path_arr)
	var _set_max_column: int = __c._setup_project._get_popup_find_column_size()
	var _result_quanty: int = _movable_count * _set_max_column

	_is_load_button = true

	var _sort_children: Array[Node]

	for container in _find_popup_panel._script_containers:
		for child in container._item_container.get_children():
			child._set_visible_status(true)
			child.reparent(_temp_container)

	_sort_children = _temp_container.get_children()
	_sort_children.sort_custom(_sort_custom_children_path)

	for child in _sort_children:
		_movable_count = _movable_count if _sc_path_arr.size() < _result_quanty else _equal_size

		if _index > 0 and _index % _movable_count == 0:
			_num += 1
			_index = 0

		if _sc_path_arr.has(child._store_path):
			var _new_parent := _find_popup_panel._script_containers[_num]._item_container
			child.reparent(_new_parent)
			_index += 1

	await get_tree().process_frame
	_find_popup_panel._label_script_size._set_label_name(_sc_path_arr.size())
	_is_load_button = false

	if _find_script._store_text != "":
		_find_popup_panel._line_edit_find.text_changed.emit(_find_script._store_text)

#endregion
################################################################################
#region _set_folder_pressed_util

func _sort_custom_children_path(_a: SMPButtonScript, _b: SMPButtonScript) -> bool:
	return _a._store_name.get_file() < _b._store_name.get_file()

func _clear_temp_container() -> void:
	for child in _temp_container.get_children():
		child.queue_free()

#endregion
################################################################################
