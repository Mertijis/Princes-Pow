@tool
class_name SMPFindPopupPanel
extends PopupPanel


""" class """
var __c: SMPClassManagers
var _dock_main: ScriptMultiPlusDock

var _script_item_list: ItemList

var _script_containers: Array[SMPContainerScript]
var _editor_filesystem: EditorFileSystemDirectory
var _sc_info_arr: Array[SMPScriptInfo]

var _store_curr_list: PackedStringArray
var _store_item_list: PackedStringArray
var _store_recent_list: PackedStringArray

var _store_setup_arr: Array:
	set(_value):
		_store_setup_arr = _value

var _current_folder_dict: Dictionary = {"index": -1}
var _store_row_size: int = -1
var _is_selected: bool = false


""" class """
@onready var _find_script: SMPFindScript = %FindScript
@onready var _editor_fs_dir: SMPFilesystemDir = %EditorFilesystemDir

""" containers """
@onready var _main_container: MarginContainer = %MainContainer
@onready var _folder_container: SMPContainerFolder = %FolderContainer
@onready var _root_script_container: HBoxContainer = %RootScriptContainer
@onready var _vsc_info: VBoxContainer = %VSCInfo

""" icons """
@onready var _icon_texture_find: TextureRect = %IconTextureFind
@onready var _icon_texture_path: TextureRect = %IconTexturePath
@onready var _icon_texture_select: TextureRect = %IconTextureSelect

""" line_edits """
@onready var _line_edit_find: LineEdit = %LineEditFind
@onready var _line_edit_path: LineEdit = %LineEditPath
@onready var _line_edit_selected: SMPLineEditSelected = %LineEditSelected

""" buttons """
@onready var _button_grab: Button = %ButtonGrab
@onready var _button_close: Button = %ButtonClose
@onready var _button_open: SMPButtonOpen = %ButtonOpen
@onready var _button_attach_2: SMPButtonOpen = %ButtonAttach2
@onready var _button_attach_3: SMPButtonOpen = %ButtonAttach3
@onready var _button_text_empty: SMPButtonTextEmpty = %ButtonTextEmpty

""" labels """
@onready var _label_extends: SMPLabelExtends = %HExtends
@onready var _label_class_name: SMPLabelClassName = %HClassName
@onready var _label_script_size: SMPLabelScriptSize = %LabelScriptSize
@onready var _label_select_folder: SMPSelectFolder = %LabelSelectFolder


##:: setup
################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	_store_setup_arr = _setup_arr

	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item
			elif item is ScriptMultiPlusDock:
				_dock_main = item
			elif item is ItemList:
				_script_item_list = item

	_set_ready()
	_get_containers()
	_set_new_class()
	_set_init_popup_panel()
	_buttons_disabled_status(true, "", "init")
	_set_ready_signal()
	_set_init_box_custom_min_size(230)

#endregion
################################################################################
#region _signal_connect

func _set_ready_signal() -> void:
	__c._setup_signal.connect_popup_hide(self, _on_popup_hide)
	__c._setup_signal.connect_gui_input(_main_container, _on_gui_input)
	__c._setup_signal.connect_gui_input(_button_close, _on_gui_input)
	__c._setup_signal.connect_gui_input(_line_edit_path, _on_gui_input)
	__c._setup_signal.connect_gui_input(_line_edit_selected, _on_gui_input)
	__c._setup_signal.connect_button_pressed(_button_close, _on_button_close_pressed)
	__c._setup_signal.connect_gui_input(_line_edit_find, _find_script._on_gui_input)
	__c._setup_signal.connect_line_edit_text_changed(_line_edit_find, _find_script._find_on_text_changed)
	__c._setup_signal.connect_text_submitted(_line_edit_find, _find_script._find_on_text_submitted)

#endregion
################################################################################


##:: status
################################################################################
#region _set_ready_status

func _set_ready() -> void:
	__c._setup_settings._set_icon_texture(_icon_texture_find, "tex")

func _setup_push_back() -> void:
	_store_setup_arr.push_back(self)
	_store_setup_arr.push_back(_find_script)
	_store_setup_arr.push_back(_editor_fs_dir)
	_store_setup_arr.push_back(_folder_container)

func _set_new_class() -> void:
	_setup_push_back()

	_find_script._setup_class(_store_setup_arr)
	_folder_container._setup_class(_store_setup_arr)
	_editor_fs_dir._setup_class(_store_setup_arr)

	_button_open._setup_class(_store_setup_arr)
	_button_attach_2._setup_class(_store_setup_arr)
	_button_attach_3._setup_class(_store_setup_arr)
	_button_text_empty._setup_class(_store_setup_arr)
	_line_edit_selected._setup_class(_store_setup_arr)
	_label_extends._setup_class(_store_setup_arr)
	_label_class_name._setup_class(_store_setup_arr)
	_label_script_size._setup_class(_store_setup_arr)
	_label_select_folder._setup_class(_store_setup_arr)
	_set_sc_infos()

func _set_init_box_custom_min_size(_size_x: int) -> void:
	%HInfoLeft.custom_minimum_size.x = _size_x
	%HInfoRight.custom_minimum_size.x = _size_x
	%HFindLeft.custom_minimum_size.x = _size_x
	%HFindRight.custom_minimum_size.x = _size_x
	%MBottomLeft.custom_minimum_size.x = _size_x
	%MBottomRight.custom_minimum_size.x = _size_x

#endregion
################################################################################
#region _set_status

func _get_column_equal_size(_result_quanty: Array) -> int:
	if _result_quanty.size() == 0:
		return 0
	var _container_column_size: int = __c._setup_project._get_popup_find_column_size()
	var _column: int = min(_container_column_size, _result_quanty.size())
	var _max_row: int = ceil(_result_quanty.size() / float(_column) + 1)
	_get_init_store_row_size(_max_row)
	#prints("column: ", _column, _max_row, _store_row_size)
	return _max_row

func _set_sc_infos() -> void:
## get
	for child in _vsc_info.get_children():
		_sc_info_arr.push_back(child)
## init
	for child: SMPScriptInfo in _sc_info_arr:
		child._setup_class(_store_setup_arr)
		child._set_info_status()

func _buttons_disabled_status(_active: bool, _path: String, _type: String) -> void:
	match _type:
		"init":
			_button_open.set_disabled(_active)
			_button_open._set_store_path(_path)
			_button_attach_2.set_disabled(_active)
			_button_attach_2._set_store_path(_path)
			_button_attach_3.set_disabled(_active)
			_button_attach_3._set_store_path(_path)
		"select":
			_button_open.set_disabled(_active)
			_button_open._set_store_path(_path)

			if _dock_main._mcontainer_1._vbox.get_child_count() > 0:
				_button_attach_2.set_disabled(_active)
				_button_attach_2._set_store_path(_path)

			if _dock_main._mcontainer_2._vbox.get_child_count() > 0:
				_button_attach_3.set_disabled(_active)
				_button_attach_3._set_store_path(_path)

func _set_nodes_font_size() -> void:
	_set_font_size(_line_edit_find)
	_set_font_size(_line_edit_path)
	_set_font_size(_line_edit_selected)
	_set_font_size(_button_open)
	_set_font_size(_button_attach_2)
	_set_font_size(_button_attach_3)

func _set_font_size(_node: Node) -> void:
	var _font_size: int = __c._setup_project._get_popup_text_size()
	__c._setup_settings._set_theme_override_font_size(_node, _font_size)
	_icon_texture_find.custom_minimum_size.x = _font_size
	_icon_texture_path.custom_minimum_size.x = _font_size
	_icon_texture_select.custom_minimum_size.x = _font_size

#endregion
################################################################################
#region _setget

func _set_visible_status(_active: bool) -> void:
	self.set_visible(_active)

func _set_is_selected_status(_active: bool) -> void:
	_is_selected = _active

func _set_line_edit_status(_type: String) -> void:
	match _type:
		"grab":
			_line_edit_find.grab_focus()
		"select":
			_line_edit_find.select_all()
		"all":
			_line_edit_find.select_all()
			_line_edit_find.grab_focus()
			_line_edit_find.edit()

func _set_editor_filesystems() -> void:
	if _editor_filesystem == null:
		_editor_filesystem = _get_editor_filesystem_dir()
		_editor_fs_dir._editor_filesystem = _editor_filesystem
		_folder_container._editor_filesystem = _editor_filesystem

func _get_editor_filesystem_dir() -> EditorFileSystemDirectory:
	return EditorInterface.get_resource_filesystem().get_filesystem()

func _get_folder_names() -> Array[String]:
	return __c._setup_project._get_project_settings_folder_names()

func _get_containers() -> void:
	for child in _root_script_container.get_children():
		_script_containers.push_back(child)

func _get_init_store_row_size(_size: int) -> void:
	if _store_row_size == -1:
		_store_row_size = _size

func _get_sett_changeable_row_size(_panel_size: float) -> void:
	var _poffset: float = 268
	var _min_size: int = 20
	var _button_size_y: float = -1
	var _ichildren := _folder_container._item_container.get_children()
	for child in _ichildren:
		if _button_size_y == -1:
			_button_size_y = child._folder_button.size.y
			break
	var _row_size_calc: float = round((_panel_size - _poffset) / _button_size_y)

	if _row_size_calc < _min_size:
		__c._setup_settings._finder_script_row_min_size = _min_size
		return
	__c._setup_settings._finder_script_row_min_size = _row_size_calc

#endregion
################################################################################


##:: popup_panel
################################################################################
#region _set_change_color_func

func _get_recent_list_data() -> void:
	_store_recent_list.clear()
	var _recent_keys: Array[String] = __c._saveload_conf._recent_keys
	for key: String in _recent_keys:
		var _ikey: int = key.to_int()
		var _rdata: Dictionary = __c._saveload_conf._get_save_data_recent_index(_ikey)
		if not _rdata.is_empty():
			for i in _rdata:
				var _sc_names: Array = _rdata[i].get("sc_name", [])
				if not _sc_names.is_empty():
					if not _store_recent_list.has(_sc_names[1]):
						_store_recent_list.push_back(_sc_names[1])

func _get_sc_list_items() -> void:
	_store_item_list.clear()
	for i: int in range(_script_item_list.item_count):
		var _text: String = _script_item_list.get_item_text(i)
		if _text.get_extension() == "gd":
			if not _store_item_list.has(_text):
				_store_item_list.push_back(_text)

func _get_sc_curr_items() -> void:
	_store_curr_list.clear()
	var _data_keys: Array[String] =__c._saveload_conf._indexs
	for key: String in _data_keys:
		if key == "index_0":
			continue
		var _sdata: Dictionary = __c._saveload_conf._get_save_data(key)
		if not _sdata.is_empty():
			for i: int in _sdata:
				var _sc_names: Array = _sdata[i].get("sc_name", [])
				if not _sc_names.is_empty():
					if not _store_curr_list.has(_sc_names[1]):
						_store_curr_list.push_back(_sc_names[1])

func _set_name_button_icon_color() -> void:
	var _icon_color: Color = __c._setup_settings._color_dict["accent_color"]
	var _text_color: Color = __c._setup_settings._color_dict["txt_color"]
	var _rcolor: Array[Color] = __c._setup_settings._set_blend_inverted_color()
	var _curr_color: Array[Color] = __c._setup_settings._set_blend_inverted_color(0.84)

	for container: SMPContainerScript in _script_containers:
		for child in container._item_container.get_children():
			if _store_recent_list.has(child._store_name):
				__c._setup_settings._set_icon_loaded_color(child, _rcolor[0], _rcolor[1])
			elif _store_item_list.has(child._store_name):
				__c._setup_settings._set_icon_loaded_color(child, _icon_color, _icon_color)
			else:
				__c._setup_settings._set_icon_closed_color(child, _text_color)

			if _store_curr_list.has(child._store_name):
				__c._setup_settings._set_icon_loaded_color(child, _curr_color[0], _curr_color[1])

#endregion
################################################################################
#region _set_popup_panel_status

func _set_init_popup_panel() -> void:
	self.size = Vector2.ZERO
	_set_visible_status(false)

func _set_panel_size() -> void:
	var _screen := DisplayServer.screen_get_size()
	var _scale_x: float = __c._setup_project._get_popup_panel_size().x
	var _scale_y: float = __c._setup_project._get_popup_panel_size().y
	self.size.x = _screen.x * clampf(_scale_x, 0.25, 0.88)
	self.size.y = _screen.y * clampf(_scale_y, 0.25, 0.88)

func _set_panel_hide() -> void:
	_set_init_opend_button()
	_clear_script_containers()
	_set_visible_status.call_deferred(false)

func _set_open_popup_panel(_control: Control) -> void:
	_set_editor_filesystems()
	_set_panel_size()
	__c._setup_settings._set_theme_override_popup_panel(self)
	self.position = _control.get_screen_position()
	_store_row_size = -1
	_editor_fs_dir._is_load_button = true
	_folder_container._is_load_button = true
	_folder_container._set_tree_items()
	_get_sett_changeable_row_size(self.size.y)
	_editor_fs_dir._set_file_subdir_init()
	_set_nodes_font_size()
	_set_visible_status(true)
	self.popup_centered()
	_set_line_edit_status("all")

func _set_init_opend_button() -> void:
	_clear_selected_script()
	_buttons_disabled_status(true, "", "init")
	_folder_container._clear_temp_container()
	_folder_container._clear_item_container_children()
	_folder_container._is_load_button = false
	_editor_fs_dir._is_load_button = false
	_find_script._store_text = ""

func _set_init_remove_selected() -> void:
	_current_folder_dict.clear()
	_current_folder_dict["index"] = -1
	_release_focus_selected_folder()
	_label_select_folder._set_init_label()
	_set_init_position_names.call_deferred(_store_row_size, "folder")

#endregion
################################################################################


##:: container
################################################################################
#region _conta_get_size

func _get_has_container_child() -> int:
	var _size: int = 0
	for container: SMPContainerScript in _script_containers:
		if container._item_container.get_child_count() > 0:
			_size += 1
			continue
		else:
			break
	return _size - 1

#endregion
################################################################################
#region _conta_get_item

func _get_selected_sc_item() -> void:
	for container: SMPContainerScript in _script_containers:
		for child: SMPButtonScript in container._item_container.get_children():
			if child._focus_panel.is_visible():
				_set_is_selected_status(false)
				child._name_button.grab_focus()
				child._set_group_focus_func()
				return

func _find_sc_container_first_item(_type: String) -> void:
	var _item_container := _script_containers[0]._item_container
	if _item_container.get_child_count() > 0:
		match _type:
			"forward":
				_find_forward_first_item(_item_container, "SMPButtonScript")
			"reverse":
				_find_reverese_end_item(_item_container, "SMPButtonScript")

func _find_folder_container_first_item(_type: String) -> void:
	var _item_container := _folder_container._item_container
	if _item_container.get_child_count() > 0:
		match _type:
			"forward":
				_find_forward_first_item(_item_container, "SMPButtonFolder")
			"reverse":
				_find_reverese_end_item(_item_container, "SMPButtonFolder")

func _find_forward_first_item(_item_container: VBoxContainer, _class: String) -> void:
	for child in _item_container.get_children():
		if child.is_visible():
			if _class == "SMPButtonFolder":
				child._folder_button.grab_focus()
			elif _class == "SMPButtonScript":
				if not _is_selected:
					child._name_button.grab_focus()
					child._set_line_edit_path(child._store_path, "hover")
				else:
					_get_selected_sc_item()
			return

func _find_reverese_end_item(_item_container: VBoxContainer, _class: String) -> void:
	var _size: int = _item_container.get_children().size()
	for count: int in range(_size -1, 0, -1):
		var child := _item_container.get_child(count)
		if child.is_visible():
			if _class == "SMPButtonFolder":
				child._folder_button.grab_focus()
			elif _class == "SMPButtonScript":
				if not _is_selected:
					child._name_button.grab_focus()
					child._set_line_edit_path(child._store_path, "hover")
				else:
					_get_selected_sc_item()
			return

#endregion
################################################################################
#region _conta_exist_child_grab

func _get_exist_folder_container_size() -> int:
	if _folder_container._item_container.get_child_count() > 0:
		var _child_size: int = _folder_container._item_container.get_children().size() -1
		return _child_size
	return 0

func _exist_folder_container_size(_current_index: int, _range: int = 0) -> void:
	if _folder_container._item_container.get_child_count() > 0:
		var _children: Array[Node] = _folder_container._item_container.get_children()
		var _child_size: int = _folder_container._item_container.get_children().size() -1
		if _current_index >= _child_size - _range:
			_children[-1]._folder_button.grab_focus()
		else:
			_children[0]._folder_button.grab_focus()

func _selected_folder_grab_focus() -> void:
	if _folder_container._item_container.get_child_count() > 0:
		var _select_index: int = _current_folder_dict["index"]
		for child in _folder_container._item_container.get_children():
			if _select_index == child._button_index_folder:
				child._folder_button.grab_focus()

func _selected_sc_item_grab_jump(_button: SMPButtonScript, _cur_index: int, _range: int) -> void:
	var _parent_index: int = _button._get_container_num()
	var _children: Array[Node] = _script_containers[_parent_index]._item_container.get_children()
	if _children.size() > 0:
		if _cur_index >= (_children.size() -1) - _range:
			_children[-1]._name_button.grab_focus()
		else:
			_children[0]._name_button.grab_focus()

#endregion
################################################################################
#region _conta_clear_release_status

func _release_focus_temp_container_children() -> void:
	for child in _folder_container._temp_container.get_children():
		if child is SMPButtonScript:
			child._set_visible_focus_panel(false)

func _release_focus_selected_folder() -> void:
	for child in _folder_container._item_container.get_children():
		if child is SMPButtonFolder:
			child._set_visible_focus_panel(false)
			child.release_focus()

func _release_focus_name_button() -> void:
	for container: SMPContainerScript in _script_containers:
		for child in container._item_container.get_children():
			child._name_button.release_focus()

func _release_visible_focus_panel() -> void:
	for container: SMPContainerScript in _script_containers:
		for child in container._item_container.get_children():
			child._set_visible_focus_panel(false)

func _clear_script_containers() -> void:
	for container: SMPContainerScript in _script_containers:
		for child in container._item_container.get_children():
			child.queue_free()

func _clear_selected_script() -> void:
	_release_visible_focus_panel()
	_set_is_selected_status(false)
	_line_edit_selected._clear_store_path()

#endregion
################################################################################


##:: init_name_label
################################################################################
#region _set_position_init_find

func _set_init_position_names(_row: int, _type: String = "") -> void:
	var _row_size: int = _row
	var _location_idx: int = 0
	var _count: int = 0

	var _temp_container := VBoxContainer.new()
	var _sort_children: Array[Node]

	for container: SMPContainerScript in _script_containers:
		for child in container._item_container.get_children():
			child._set_visible_status(true)
			child.reparent(_temp_container)

	if _type == "folder":
		var _temp_folder_container := _folder_container._temp_container
		for child in _temp_folder_container.get_children():
			child._set_visible_status(true)
			child.reparent(_temp_container)

	_sort_children = _temp_container.get_children()
	_sort_children.sort_custom(_sort_custom_path)

	for child in _sort_children:
		if _count >= _row_size:
		#if _count >= _row_size:
			_location_idx += 1
			_count = 0

		var _new_parent := _script_containers[_location_idx]._item_container
		child.reparent(_new_parent)
		_count += 1

	await get_tree().process_frame
	_label_script_size._set_label_name(_sort_children.size())

func _sort_custom_path(_a: SMPButtonScript, _b: SMPButtonScript) -> bool:
	return _a._store_name.get_file() < _b._store_name.get_file()

#endregion
################################################################################


##:: signal
################################################################################
#region _signal On_connect

func _on_button_close_pressed() -> void:
	_set_panel_hide()

func _on_popup_hide() -> void:
	_set_panel_hide()

func _on_gui_input(_event: InputEvent) -> void:
	if _event is InputEventMouseButton:
		if _event.pressed and _event.button_index == MOUSE_BUTTON_LEFT:
			_main_container.grab_focus()

	## focus_release click_right
		elif _event.pressed and _event.button_index == MOUSE_BUTTON_RIGHT:
			if _line_edit_path.has_focus() or _line_edit_selected.has_focus():
				return
			_clear_selected_script()
			_release_focus_name_button()
			_release_focus_temp_container_children()

	if _event is InputEventKey:
		if _line_edit_selected.has_focus():
			if _select_key_allow(KEY_LEFT, _event):
				_find_folder_container_first_item.call_deferred("reverse")
			elif _select_key_allow(KEY_UP, _event):
				_find_sc_container_first_item.call_deferred("reverse")

		elif _event.pressed and _event.keycode == KEY_BACKSPACE:
			_clear_selected_script()
			_release_focus_temp_container_children()

		elif _event.pressed and _event.keycode == KEY_F:
			_set_line_edit_status("all")

		elif _line_edit_path.has_focus():
			if _select_key_allow(KEY_UP, _event):
				_find_sc_container_first_item.call_deferred("reverse")

		elif _button_close.has_focus():
			if _select_key_allow(KEY_RIGHT, _event):
				_find_folder_container_first_item.call_deferred("forward")

			elif _select_key_allow(KEY_DOWN, _event):
				await get_tree().process_frame
				_find_sc_container_first_item.call_deferred("forward")

	## buttons_open_attach
		if _button_open.has_focus():
			if _select_key_alt_pressed(_event, KEY_J):
				_button_attach_3.grab_focus()
			elif _select_key_alt_pressed(_event, KEY_L):
				_button_attach_2.grab_focus()

		elif _button_attach_2.has_focus():
			if _select_key_alt_pressed(_event, KEY_J):
				_button_open.grab_focus()
			elif _select_key_alt_pressed(_event, KEY_L):
				_button_attach_3.grab_focus()

		elif _button_attach_3.has_focus():
			if _select_key_alt_pressed(_event, KEY_J):
				_button_attach_2.grab_focus()
			elif _select_key_alt_pressed(_event, KEY_L):
				_button_open.grab_focus()

#endregion
################################################################################
#region _event_key_func

func _select_key_alt_pressed( _event: InputEventKey, _key_1: Key) -> bool:
	if _event.pressed and _event.alt_pressed and _event.keycode == _key_1:
		return true
	return false

func _select_key_allow(_key_1: Key, _event: InputEventKey) -> bool:
	if _event.pressed and _event.keycode == _key_1:
		return true
	return false

#endregion
################################################################################

