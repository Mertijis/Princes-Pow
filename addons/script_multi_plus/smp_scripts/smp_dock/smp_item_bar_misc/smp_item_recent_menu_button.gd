@tool
class_name SMPRecentMenuButton
extends SMPItemButtonParent


var _timer_sc_closed: SMPTimerUtility
var _timer_sc_moved: SMPTimerUtility

var _button_index: int = 0

## assign_from_smp_recent_button
var _exist_opened_script_id: int = -1

var _store_menu_index: int = -1
var _store_max_recent: int

var _recent_data: Dictionary
var _store_recent_keys: Array[String]
var _store_orig_paths: PackedStringArray
var _opened_script_names: Array[String]

var _menu_index_item: Dictionary[String, int]
var _sc_closed_item_dict: Dictionary[String, Array]

var _is_files_moved: bool = false
var _is_selected_press: bool = false


@onready var _recent_popup_panel: SMPRecentPopupPanel = %RecentPopupPanel


##:: ready_status
################################################################################
#region _ready_signal

func _set_ready_signal() -> void:
	__c._setup_signal.connect_button_pressed(self, _on_button_pressed)
	__c._setup_signal.connect_visibility_changed(_recent_popup_panel, _on_visibility_changed)
	__c._setup_signal.connect_files_moved(_plugin._filesystem_dock, _on_files_moved)
	__c._setup_signal.connect_child_order_changed(_plugin._tab_container, _on_tab_cont_child_order_changed)

#endregion
################################################################################
#region _ready_status

func _set_ready_status() -> void:
	_timer_sc_closed = SMPTimerUtility.new(_dock_main)
	_timer_sc_moved = SMPTimerUtility.new(_dock_main)

	_store_recent_keys = __c._saveload_conf._recent_keys
	_store_max_recent = __c._setup_project._get_popup_recent_size()
	_button_index = _get_button_index()
	_set_icon_status()
	_set_default_menu()
	_set_menu_index_table_init()

func _set_icon_status() -> void:
	self.icon = __c._setup_settings._icon_dict["recent"]
	self.tooltip_text = __c._setup_settings._tooltip_dict["recent"] % _get_tooltip_text()
	__c._setup_settings._set_icon_alignment(self, "right")
	__c._setup_settings._set_icon_custom_min_size_x(self, __c._setup_settings._min_size_x["recent"])

func _get_button_index() -> int:
	var _owner: SMPDockContainer = __c._setup_utility._find_parent_dock_container(self)
	return _owner.container_index

func _exs_check_sc_list() -> void:
	_set_opened_scripts()
	_change_has_button_disable()

func _set_menu_index_table(_save_key: String, _menu_index: int) -> Dictionary:
	_menu_index_item[_save_key] = _menu_index
	return _menu_index_item

func _set_menu_index_table_init() -> void:
	_menu_index_item = {
		"recent_1": -1,
		"recent_2": -1,
		"recent_3": -1,
	}

func _get_tooltip_text() -> String:
	var _ikey:InputEventKey = __c._setup_project._inputkey_dict["OpenRecent"]
	var _key_text: String = _ikey.as_text_keycode()
	return _key_text

#endregion
################################################################################
#region _button_status

func _set_default_menu() -> void:
	_clear_vbox_children()
	var _item_button: SMPRecentButton = _ins_item_button()
	var _item_line: MarginContainer = _ins_item_line()
	_recent_popup_panel._set_add_child(_item_button)
	_recent_popup_panel._set_add_child(_item_line)
	_item_button._setup_class(__c._setup_arr)
	_item_button._set_add_item("Recent Clear", 0, _button_index, false)
	_recent_popup_panel.unfocusable = true

func _set_init_button_checked() -> void:
	if _get_vbox_child_item_count() > 0:
		for child in _get_vbox_children():
			if child is SMPRecentButton:
				if child._store_id > 1:
					child._set_icon_texture("uchk")

func _change_has_button_disable() -> void:
	var _tkey: String = "recent_%s_t" % _button_index
	var _fkey: String = "recent_%s_f" % _button_index
	var _tdisable: Array
	var _fdisable: Array
	if _get_vbox_child_item_count() > 0:
		for child in _get_vbox_children():
			if child is SMPRecentButton:
				if child._store_id > 1:
					if not _opened_script_names.has(child._store_name):
						_tdisable.push_back(child._store_id)
						child._set_icon_texture("uchk")
						child._set_button_focus_bg_alpha(child._name_button, "dis")
						child._set_button_disabled_state(true)
					else:
						_fdisable.push_back(child._store_id)
						child._set_button_focus_bg_alpha(child._name_button, "nom")
						child._set_button_disabled_state(false)
		_set_closed_table(_tkey, _tdisable)
		_set_closed_table(_fkey, _fdisable)

func _changeable_recent_max_size() -> void:
	var _ps_recent_size: int = __c._setup_project._get_popup_recent_size()
	if _store_max_recent > _ps_recent_size:
		_store_max_recent = _ps_recent_size
	else:
		_store_max_recent = _ps_recent_size

#endregion
################################################################################
#region setget_status

func _is_files_moved_state(_active: bool) -> void:
	_is_files_moved = _active

func _is_visible_recent_panel() -> bool:
	return _recent_popup_panel.visible

func _get_vbox_child_item_count() -> int:
	return _recent_popup_panel._vbox.get_child_count()

func _get_vbox_children() -> Array[Node]:
	return _recent_popup_panel._vbox.get_children()

func _set_closed_table(_save_key: String, _ids: Array) -> Dictionary:
	_sc_closed_item_dict[_save_key] = _ids
	return _sc_closed_item_dict

func _set_closed_table_init() -> void:
	_sc_closed_item_dict.clear()

func _set_panel_position() -> void:
	var _offset := Vector2(-32, 28)
	_recent_popup_panel.set_size(Vector2.ZERO)
	_recent_popup_panel.position = get_screen_position() + _offset
	_recent_popup_panel.visible = true

func _set_store_paths(_orig_path: String) -> void:
	if not _store_orig_paths.has(_orig_path):
		_store_orig_paths.push_back(_orig_path)

func _set_opened_scripts() -> void:
	var _sc_names: Array[String]
	var _opened_scripts: Array[Script] = _plugin._script_editor.get_open_scripts()
	for sc: Script in _opened_scripts:
		_sc_names.push_back(sc.resource_path.get_file())
	_opened_script_names = _sc_names

func _clear_store_paths() -> void:
	_store_orig_paths.clear()

func _clear_vbox_children() -> void:
	for child in _get_vbox_children():
		child.queue_free()

#endregion
################################################################################
#region set_misc

func _set_focus_item() -> void:
	var _menu_index_dict := __c._saveload_conf._load_data_menu_index(_button_index)
	var _curr_index: int = _menu_index_dict.get("menu_index", -1)
	if _curr_index != -1:
		if _get_vbox_child_item_count() > 0:
			for child in _get_vbox_children():
				if child is SMPRecentButton:
					if child._store_id == _curr_index:
						child._set_grab_focus_button()

func _set_neighbors() -> void:
	var _button_arr: Array[SMPRecentButton]
	if _get_vbox_child_item_count() > 0:
		for child in _get_vbox_children():
			if child is SMPRecentButton:
				_reset_neighbors(child._name_button)
				child._set_store_owner(self)
				_button_arr.push_back(child)
		if _button_arr.size() > 1:
			var _item_first := _button_arr[0]._name_button
			var _item_last := _button_arr[-1]._name_button
			_item_first.focus_neighbor_top = _item_last.get_path()
			_item_last.focus_neighbor_bottom = _item_first.get_path()

func _reset_neighbors(_control: Control) -> void:
	_control.focus_neighbor_top = ""
	_control.focus_neighbor_bottom = ""

#endregion
################################################################################


##:: item_status
################################################################################
#region item_data_tables

func _data_table(_data: Dictionary) -> Dictionary:
	var _table: Dictionary = {
			"focus_index" : _data["focus_index"],
			"tab_index"   : _data["tab_index"],
			"sc_name"     : _data["sc_name"],
			"script_path" : _data["script_path"],
			"uid_path"    : _data["uid_path"],
		}
	return _table

func _data_table_menu_index(_menu_index: int) -> Dictionary:
	var _table: Dictionary = {
			"menu_index" : _menu_index,
		}
	return _table

#endregion
################################################################################
#region item_instance

func _ins_item_button() -> SMPRecentButton:
	var _scene_res := __c._setup_settings._scene_popup_res
	var _scene_button: SMPRecentButton = _scene_res["recent_button"].instantiate()
	return _scene_button

func _ins_item_line() -> MarginContainer:
	var _scene_res := __c._setup_settings._scene_popup_res
	var _scene_line: MarginContainer = _scene_res["recent_line"].instantiate()
	return _scene_line

#endregion
################################################################################
#region item_add_button

func _set_add_radio_button(_cont_data: Dictionary, _id: int, _active: bool, _type: String) -> void:
	match _type:
		"set":
			var _table: Dictionary = _data_table(_cont_data)
			var _label: String = _table["script_path"].get_file()
			var _item_button: SMPRecentButton = _ins_item_button()
			_recent_popup_panel._set_add_child(_item_button)

			_item_button._setup_class(__c._setup_arr)
			_item_button._set_store_owner(self)
			_item_button._set_add_item(_label, _id, _button_index, _active)
			_item_button._store_cont_data = _cont_data.duplicate()

		"pressed":
			for child in _get_vbox_children():
				if child is SMPRecentButton:
					var _item: SMPRecentButton = child
					if _item._store_id == _id:
						_item._set_item_checked(_active)

#endregion
################################################################################


##:: handle
################################################################################
#region handle_process

func _handle_menu_items(_cont_data: Dictionary) -> void:
	if _is_selected_press:
		return
	var _table: Dictionary = _data_table(_cont_data)
	var _item_index: int = _get_vbox_child_item_count()
	_changeable_recent_max_size()
	_set_init_button_checked()

	if not _store_orig_paths.has(_table["script_path"]):
		## add_new_item
		_set_store_paths(_table["script_path"])
		_set_add_radio_button(_cont_data, _item_index, true, "set")
		_store_menu_index = _item_index
		_recent_data[_item_index] = _table
		#print("recent_data_add:", _recent_data)
		#print("store_orig_path: ", _store_orig_paths)

		if _item_index > _store_max_recent + 1:
			## remove_item = index_2
			for child in _get_vbox_children():
				if child is SMPRecentButton:
					if child._store_id == 2:
						child.queue_free()
						break
			await get_tree().process_frame
			_menu_over_max_size(_item_index)
			return
		_saving_menu_index(_store_menu_index)
		_saving_recent_data(_recent_data, "add")
		_update_moved_sc_list()
	else:
		_menu_same_item_changed(_cont_data)
		_update_moved_sc_list()

#endregion
################################################################################
#region handle_menu_func

func _menu_over_max_size(_index: int) -> void:
	_clear_store_paths()
	_recent_data = _get_after_moved()
	_store_menu_index = _index -1
	_saving_menu_index(_store_menu_index)
	_saving_recent_data(_recent_data, "rebuild")

func _menu_same_item_changed(_cont_data: Dictionary) -> void:
	var _current_item: SMPRecentButton = _get_current_item(_cont_data)
	_clear_store_paths()
	_recent_data = _get_after_moved()
	_current_item._set_item_checked(true)
	_store_menu_index = _current_item._store_id
	_saving_menu_index(_current_item._store_id)
	_saving_recent_data(_recent_data, "rebuild")

#endregion
################################################################################
#region handle_moved_func

func _get_current_item(_cont_data: Dictionary) -> SMPRecentButton:
	var _recent_items: Array[Node] = _get_vbox_children()
	for child in _recent_items:
		if child is SMPRecentButton:
			if child._store_id < 1:
				continue
			if child._store_path == _cont_data["script_path"]:
				child._store_cont_data = _cont_data.duplicate()
				child.get_parent().move_child(child, -1)
				return child
	return null

func _get_after_moved() -> Dictionary:
	var _recent_items: Array[Node] = _get_vbox_children()
	var _temp: Dictionary[int, Dictionary]
	for child in _recent_items:
		if child is SMPRecentButton:
			if child._store_id < 1:
				continue
			_set_store_paths(child._store_path)
			child._store_id = child.get_index()
			_temp[child._store_id] = _data_table(child._get_cont_data_status())
	return _temp

#endregion
################################################################################


##:: signal
################################################################################
#region sig_ is_On_connected

func _check_is_connected() -> void:
	for child in _get_vbox_children():
		if child is SMPRecentButton:
			if not child.is_connected("selected_item", _on_selected_item):
				child.selected_item.connect(_on_selected_item)

func _on_selected_item(_id: int) -> void:
	if _id != 0:
		_pressed_menu_changed_script(_id)
	else:
		_pressed_menu_clear()
	_recent_popup_panel.visible = false

#endregion
################################################################################
#region sig_ On_connected

func _on_visibility_changed() -> void:
	if _recent_popup_panel.visible:
		self_modulate = __c._setup_settings._color_dict["accent_color"]
	else:
		self_modulate = Color.WHITE

func _on_button_pressed() -> void:
	_set_neighbors()
	_set_panel_position()
	_check_is_connected()
	_dock_main._store_focus_index = _button_index

func _on_tab_cont_child_order_changed() -> void:
	_set_opened_scripts()
	_change_has_button_disable()
	_reselect_after_closed()
	_timer_sc_closed._set_timer_start_auto(0.2, 1, 1, _on_timeout_sc_closed)

func _on_timeout_sc_closed() -> void:
	_timer_sc_closed._init_timeout_auto()
	_set_closed_table_init()
	_update_moved_sc_list()

#endregion
################################################################################
#region sig_ On_pressed

func _pressed_menu_changed_script(_id: int) -> void:
	for key: int in _recent_data:
		if key == _id:
			_is_selected_press = true

			if _check_is_loaded_script(_recent_data[key]):
				_set_pressed_data(_store_menu_index)
				_set_init_button_checked()
				_set_add_radio_button({}, _store_menu_index, true, "pressed")
				_saving_menu_index(_store_menu_index)
				_check_focus_loaded_script()
				_exist_opened_script_id = -1
				break

			var _tindex: int = _recent_data[key]["tab_index"]
			_store_menu_index = _id
			_set_pressed_data(key)
			_dock_main._handler_swap_script(_button_index, _tindex)
			_set_init_button_checked()
			_set_add_radio_button({}, _id, true, "pressed")
			_saving_menu_index(_id)
			break

	_is_selected_press = false
	_exist_opened_script_id = -1

#endregion
################################################################################
#region sig_ on_pressed_func

func _check_is_loaded_script(_recent_data: Dictionary) -> bool:
	for dict: Dictionary in _dock_main._get_scte_arr():
		var _sc_names: Array = dict.get("sc_name", [])
		var _data_names: Array = _recent_data.get("sc_name", [])
		if not _sc_names.is_empty() and not _data_names.is_empty():
			if _recent_data["sc_name"][1] == _sc_names[1]:
				return true
	return false

func _check_focus_loaded_script() -> bool:
	var _temp: Dictionary
	for key: int in _recent_data:
		if key == _exist_opened_script_id:
			_temp = _recent_data[key]

	for dict: Dictionary in _dock_main._get_scte_arr():
		var _sc_names: Array = dict.get("sc_name", [])
		var _findex: int = dict.get("focus_index", -1)
		var _vsplit := dict.get("parent")

		if not _sc_names.is_empty():
			var _temp_names: Array = _temp.get("sc_name", [])
			if not _temp_names.is_empty():
				if _temp["sc_name"][1] == _sc_names[1]:
					var _mcont := _dock_main._get_focus_mcontainer(_findex)
					_mcont._check_is_connected(_vsplit, "connect")
					_dock_main._store_focus_index = _findex
					_mcont._code_edit.grab_focus.call_deferred()
					return true
	return false

func _set_pressed_data(key: int) -> void:
	var _mcont := _dock_main._get_focus_mcontainer(_button_index)
	var _sc_names: Array = _recent_data[key].get("sc_name", [])
	if not _sc_names.is_empty():
		_mcont._store_sc_names = _sc_names
		_mcont._store_script_path = _recent_data[key]["script_path"]
		_mcont._store_script_path_uid = _recent_data[key]["uid_path"]
		_mcont._dock_item_bar._item_rich_name._set_rich_label_name(_sc_names)

func _pressed_menu_clear() -> void:
	_clear_vbox_children()
	_clear_store_paths()
	_set_default_menu()
	_recent_data.clear()
	_store_menu_index = -1
	__c._saveload_conf._clear_data_recent.call_deferred(_button_index)

#endregion
################################################################################
#region sig_ files_moved

func _on_files_moved(_old_file: String, _new_file: String) -> void:
	if _old_file.get_extension() == "gd":
		#prints("files_moved_recent: ", _old_file, _new_file)
		var _rkeys: Array[String] = __c._saveload_conf._recent_keys
		__c._saveload_filesystem._handle_files_moved(
			_old_file, _new_file, _rkeys, _button_index
			)

func _update_moved_sc_list() -> void:
	_timer_sc_moved._set_timer_start_auto(0.4, 1, 1, _on_timeout_sc_list_moved)

func _on_timeout_sc_list_moved() -> void:
	_timer_sc_moved._init_timeout_auto()
	__c._saveload_filesystem._update_move_recent_data.call_deferred(_recent_data, _button_index)

#endregion
################################################################################


##:: saveload
################################################################################
#region save_recent

func _saving_menu_index(_current_index: int) -> void:
	__c._saveload_conf._save_data_menu_index(
		_data_table_menu_index(_current_index), _button_index
		)

func _saving_recent_data(_data: Dictionary, _type: String) -> void:
	__c._saveload_conf._save_data_struct_recent(
		_data, _store_menu_index, _button_index, _type
		)

#endregion
################################################################################
#region load_recent

func _loading_recent_data() -> void:
	var _menu_index_dict := __c._saveload_conf._load_data_menu_index(_button_index)
	_recent_data = __c._saveload_conf._load_data_recent(_button_index)
	_loading_label(_recent_data, _menu_index_dict, "set")

func _loading_label(_recent_data: Dictionary, _menu_index_dict: Dictionary, _type: String) -> void:
	if not _recent_data.is_empty():
		for key_int: int in _recent_data:
			var _data: Dictionary = _recent_data.get(key_int, {})

			if not _data.is_empty():
				var _label: String = _data.get("script_path", "")
				if _label != "":
					_set_store_paths(_label)
					_set_add_radio_button(_data, key_int, false, "set")

		if _type == "set":
			var _id: int = _menu_index_dict.get("menu_index", -1)
			if _id != -1:
				_set_add_radio_button({}, _id, true, "pressed")
				_store_menu_index = _id
				_set_protect_data(_id)

func _refresh_file_process() -> void:
	_clear_store_paths()
	_set_default_menu()
	_loading_label(_recent_data, {}, "set")

#endregion
################################################################################
#region load_protect_menu_index

func _set_protect_data(_id: int) -> void:
	if _id != -1:
		var _save_key: String = "recent_%s" % _button_index
		_set_menu_index_table(_save_key, _id)
	else:
		var _menu_indexs: Dictionary = _menu_index_item
		var _children: Array[Node] = _get_vbox_children()

		for key in _menu_indexs.keys():
			var _key_int: int = key.to_int()

			if _key_int != _button_index:
				continue
			var _index: int = _menu_indexs.get(key, -1)

			if _index == -1:
				continue

			for child in _children:
				if child is SMPRecentButton:
					if child._store_id == _index:
						_store_menu_index = _index
						child._set_icon_texture("chk")
						_saving_menu_index(_index)
						break
		_set_menu_index_table_init()

#endregion
################################################################################


##:: reselect
################################################################################
#region reselect_func

func _reselect_item(_index: int) -> void:
	_store_menu_index = _index
	_on_selected_item(_index)

#endregion
################################################################################
#region reselect_files_moved

func _reselect_after_moved() -> void:
	var _menu_index_dict := __c._saveload_conf._load_data_menu_index(_button_index)
	var _curr_index: int = _menu_index_dict.get("menu_index", -1)
	if _curr_index != -1:
		_reselect_item(_curr_index)

#endregion
################################################################################
#region reselect_file_removed

func _reselect_after_removed() -> void:
	var MAX_SIZE: int = _recent_data.size() + 2
	var MIN_SIZE: int = 2
	var _recent_size: int = __c._setup_project._get_popup_recent_size()
	var _menu_index_dict := __c._saveload_conf._load_data_menu_index(_button_index)
	var _removed_indexs: Dictionary = __c._saveload_filesystem._file_removed_item_dict
	var _curr_index: int = _menu_index_dict.get("menu_index", -1)

	for key: String in _removed_indexs.keys():
		var _key_int: int = key.to_int()

		if _key_int != _button_index:
			continue

		var _store_index: int = _removed_indexs.get(key, -1)

		if _store_index == -1:
			_reselect_item(_curr_index)
			continue

		if _store_index != -1:
			if _curr_index < _store_index:
				_reselect_item(_curr_index)

			elif _curr_index >= _store_index:
				var _reselect_index: int = _curr_index - 1

				if _reselect_index == 1:
					_reselect_item(0)
					return

				if _curr_index > MIN_SIZE:
					## select_MAX
					if MAX_SIZE == _curr_index:
						_reselect_item(_reselect_index)
						return
					## select_MID
					if _recent_size > 3:
						_reselect_item(_reselect_index)
						return
				_reselect_item(_store_index)

#endregion
################################################################################
#region reselect_sc_closed

func _reselect_after_closed() -> void:
	var _menu_index_dict := __c._saveload_conf._load_data_menu_index(_button_index)
	var _closed_indexs: Dictionary = _sc_closed_item_dict
	var _curr_index: int = _menu_index_dict.get("menu_index", -1)

	for key: String in _closed_indexs.keys():
		var _key_int: int = key.to_int()

		if _key_int != _button_index:
			continue
		var _darr: Array = _get_recent_numbers(_closed_indexs)
		var _t: Array = _darr[0]
		var _f: Array = _darr[1]

		if _t.is_empty():
			_reselect_item(_curr_index)
			continue

		if not _t.has(_curr_index):
			_reselect_item(_curr_index)
			continue
		else:
			if not _f.is_empty():
				_reselect_item(_f[-1])
				return

func _get_recent_numbers(_dict: Dictionary) -> Array:
	var _t: Array
	var _f: Array
	for key: String in _dict.keys():
		var _key_int: int = key.to_int()

		if _key_int != _button_index:
			continue
		if key.ends_with("t"):
			_t = _dict.get(key, [])
		if key.ends_with("f"):
			_f = _dict.get(key, [])
	return [_t, _f]

#endregion
################################################################################



