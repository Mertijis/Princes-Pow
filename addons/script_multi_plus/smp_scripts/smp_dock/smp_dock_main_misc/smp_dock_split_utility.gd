@tool
class_name SMPSplitUtility
extends Resource


var _self_index: int = 0

""" class """
var __c: SMPClassManagers
var _dock_main: ScriptMultiPlusDock

var _save_key: Dictionary
var _offset: int = 225


##:: setup
################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is ScriptMultiPlusDock:
				_dock_main = item
			elif item is SMPClassManagers:
				__c = item

	_save_key = __c._setup_settings._save_key_name

#endregion
################################################################################
##:: utility
#region util_dock_split

func _get_load_data_dict() -> Array:
	var _index_key: String = __c._saveload_conf._indexs[0]
	var _section: String = __c._setup_settings._section
	if __c._godot_conf.has_section_key(_section, _index_key):
		var _key_int: int = _index_key.to_int()
		var _load_data: Dictionary[int, Dictionary] = __c._godot_conf.get_value(_section, _index_key)
		return [_key_int, _load_data]
	return []

func _is_godot_conf_value(_find_key: String) -> bool:
	var _load_data_arr: Array = _get_load_data_dict()

	if not _load_data_arr.is_empty():
		var _key_int: int = _load_data_arr[0]
		var _load_data: Dictionary = _load_data_arr[1]

		var _key_name: String = _save_key[_find_key]
		if _load_data[_key_int].has(_key_name):
			return true
	return false

func _get_container_value(_name: String) -> int:
	var _load_data_arr: Array = _get_load_data_dict()

	if not _load_data_arr.is_empty():
		var _key_int: int = _load_data_arr[0]
		var _load_data: Dictionary = _load_data_arr[1]

		var _key_name: String = _save_key[_name]
		for key in _load_data[_key_int]:
			if key == _key_name:
				return _load_data[_key_int][key]
	return -1

#endregion
################################################################################


##:: init_status
################################################################################
#region init_boot

func _set_half_split_offset() -> void:
	if not __c._saveload_conf._has_check_index_data("index_0"):
		_dock_main._dock_split.split_offset = _dock_main.size.x /1.7
		_save_param_split_offset(_save_key["dock_1H"], _dock_main.size.x /1.7)

func _visible_header_select_all() -> void:
	_visible_header_select_cont(_dock_main._mcontainer_1, 1, true)
	_visible_header_select_cont(_dock_main._mcontainer_2, 2, true)
	_visible_header_select_cont(_dock_main._mcontainer_3, 3, true)

func _visible_header_select_cont(
	_cont: SMPDockContainer, _findex: int, _active: bool
	) -> void:
	__c._item_exp_setter._set_focus_expand_selected_cont(_cont, _findex, _active)

	## is_drawing_minimap
	var _section: String = __c._setup_settings._section
	var _indexs: Array[String] = __c._saveload_conf._indexs
	for key in _indexs:
		var _key_int: int = key.to_int()
		if _key_int == _findex:
			if __c._saveload_conf._has_check_index_data(key):
				var _data: Dictionary = __c._godot_conf.get_value(_section, key)
				var _mbool: bool = _data[_findex].get("minimap", true)
				var _mcont := _dock_main._get_focus_mcontainer(_findex)
				if _active:
					_mcont._set_minimap_draw(_mbool)

#endregion
################################################################################


##:: change_button
################################################################################
#region change_vert_button_D

func _change_dock_split_vert_button_D(_type_D: String = "D") -> void:
	if not _dock_main._dock_split.vertical:
		if not _is_godot_conf_value("dock_1HD"):
			_dock_main._dock_split.split_offset = _dock_main.size.x /1.7
			_save_param_split_offset(
				_save_key["dock_1HD"], _dock_main._dock_split.split_offset
				)
		else:
			if _type_D != "":
				_dock_main._dock_split.split_offset = _get_container_value("dock_1HD")
			else:
				_dock_main._dock_split.split_offset = _get_container_value("dock_1H")
	else:
		if not _is_godot_conf_value("dock_1VD"):
			_dock_main._dock_split.split_offset = -_dock_main.size.y / 2
			_save_param_split_offset(
				_save_key["dock_1VD"], _dock_main._dock_split.split_offset
				)
		else:
			if _type_D != "":
				_dock_main._dock_split.split_offset = _get_container_value("dock_1VD")
				_visible_header_select_all()
			else:
				_dock_main._dock_split.split_offset = _get_container_value("dock_1V")
				_visible_header_select_all()

	if not _dock_main._dock_split2.vertical:
		if not _is_godot_conf_value("dock_2HD"):
			_dock_main._dock_split2.split_offset = 0
			_save_param_split_offset(
				_save_key["dock_2HD"], _dock_main._dock_split2.split_offset
				)
		else:
			if _type_D != "":
				_dock_main._dock_split2.split_offset = _get_container_value("dock_2HD")
			else:
				_dock_main._dock_split2.split_offset = _get_container_value("dock_2H")
	else:
		if not _is_godot_conf_value("dock_2VD"):
			_dock_main._dock_split2.split_offset = _dock_main.size.y / 4
			_save_param_split_offset(
				_save_key["dock_2VD"], _dock_main._dock_split2.split_offset
				)
		else:
			if _type_D != "":
				_dock_main._dock_split2.split_offset = _get_container_value("dock_2VD")
				_visible_header_select_cont(_dock_main._mcontainer_2, 2, true)
			else:
				_dock_main._dock_split2.split_offset = _get_container_value("dock_2V")
				_visible_header_select_cont(_dock_main._mcontainer_2, 2, true)

#endregion
################################################################################
#region change_vert_button

func _change_dock_split_1_vert_button(_is_vert: bool) -> void:
	if not _is_vert:
		if not _is_godot_conf_value("dock_1H"):
			_dock_main._dock_split.split_offset = _dock_main.size.x /1.7
		else:
			_dock_main._dock_split.split_offset = _get_container_value("dock_1H")

		if not _dock_main._dock_split2.vertical:
			if not _is_godot_conf_value("dock_2H"):
				_dock_main._dock_split2.split_offset = 0
				_save_param_split_offset(
					_save_key["dock_2H"], _dock_main._dock_split2.split_offset
					)
			else:
				_dock_main._dock_split2.split_offset = _get_container_value("dock_2H")
		else:
			if not _is_godot_conf_value("dock_2V"):
				_dock_main._dock_split2.split_offset = 0
				_save_param_split_offset(
					_save_key["dock_2V"], _dock_main._dock_split2.split_offset
					)
			else:
				_dock_main._dock_split2.split_offset = _get_container_value("dock_2V")
	else:
		if not _is_godot_conf_value("dock_1V"):
			_dock_main._dock_split.split_offset = -_dock_main.size.y / 2
			_save_param_split_offset(
				_save_key["dock_1V"], _dock_main._dock_split.split_offset
				)
		else:
			_dock_main._dock_split.split_offset = _get_container_value("dock_1V")
			_visible_header_select_all()

		if not _dock_main._dock_split2.vertical:
			if not _is_godot_conf_value("dock_2H"):
				_dock_main._dock_split2.split_offset = 0
			else:
				_dock_main._dock_split2.split_offset = _get_container_value("dock_2H")
		else:
			if not _is_godot_conf_value("dock_2V"):
				_dock_main._dock_split2.split_offset = _dock_main.size.y / 4
			else:
				_dock_main._dock_split2.split_offset = _get_container_value("dock_2V")

func _change_dock_split_2_vert_button(_is_vert: bool, _type_D: String = "") -> void:
	if not _is_vert:
		if not _is_godot_conf_value("dock_2H"):
			_dock_main._dock_split2.split_offset = 0
			_save_param_split_offset(
				_save_key["dock_2H"], _dock_main._dock_split2.split_offset
				)
		else:
			_dock_main._dock_split2.split_offset = _get_container_value("dock_2H")
	else:
		if not _is_godot_conf_value("dock_2V"):
			_dock_main._dock_split2.split_offset = 0
			_save_param_split_offset(
				_save_key["dock_2V"], _dock_main._dock_split2.split_offset
				)
		else:
			_dock_main._dock_split2.split_offset = _get_container_value("dock_2V")
			_visible_header_select_cont(_dock_main._mcontainer_2, 2, true)

#endregion
################################################################################


##:: signal
################################################################################
#region sig drag_started

func _on_dock_split_1HV_drag_started() -> void:
	_check_is_connected("connect_2", _dock_main._mcontainer_2)

func _on_dock_split_2HV_drag_started() -> void:
	_check_is_connected("connect_3", _dock_main._mcontainer_3)

#endregion
################################################################################
#region sig drag_ended

func _on_dock_split_1HV_drag_ended() -> void:
	var _type_D: String = ""
	if _dock_main._is_distract_button:
		_type_D = "D"
	if not _dock_main._dock_split.vertical:
		_save_param_split_offset(_save_key["dock_1H%s" % _type_D], _dock_main._dock_split.split_offset)
	else:
		_save_param_split_offset(_save_key["dock_1V%s" % _type_D], _dock_main._dock_split.split_offset)

	_check_is_connected("disconnect_2", _dock_main._mcontainer_2)

func _on_dock_split_2HV_drag_ended() -> void:
	var _type_D: String = ""
	if _dock_main._is_distract_button:
		_type_D = "D"
	if not _dock_main._dock_split2.vertical:
		_save_param_split_offset(_save_key["dock_2H%s" % _type_D], _dock_main._dock_split2.split_offset)
	else:
		_save_param_split_offset(_save_key["dock_2V%s" % _type_D], _dock_main._dock_split2.split_offset)

	_check_is_connected("disconnect_3", _dock_main._mcontainer_3)

#endregion
################################################################################
#region sig resized

func _on_dock_split_1HV_resized() -> void:
	if not _dock_main._dock_split.vertical:
		if _dock_main._mcontainer_1.size.x < _offset:
			_visible_header_select_cont(_dock_main._mcontainer_1, 1, false)

		if _dock_main._mcontainer_2.size.x < _offset:
			_visible_header_select_cont(_dock_main._mcontainer_2, 2, false)

			if _dock_main._dock_split2.vertical:
				_visible_header_select_cont(_dock_main._mcontainer_3, 3, false)

			elif _dock_main._mcontainer_2.size.x < 20:
				_visible_header_select_cont(_dock_main._mcontainer_3, 3, false)
		else:
			if _dock_main._mcontainer_1.size.x > _offset:
				_visible_header_select_all()

func _on_dock_split_2HV_resized() -> void:
	if not _dock_main._dock_split2.vertical:
		if _dock_main._mcontainer_3.size.x < _offset:
			_visible_header_select_cont(_dock_main._mcontainer_3, 3, false)
		else:
			_visible_header_select_cont(_dock_main._mcontainer_3, 3, true)

		if _dock_main._mcontainer_2.size.x < _offset:
			_visible_header_select_cont(_dock_main._mcontainer_2, 2, false)
		else:
			_visible_header_select_cont(_dock_main._mcontainer_2, 2, true)

#endregion
################################################################################
#region sig is_connect

func _check_is_connected(_type: String, _cont: SMPDockContainer) -> void:
	match _type:
		"disconnect_2":
			if _cont.is_connected("resized", _on_dock_split_1HV_resized):
				_cont.disconnect("resized", _on_dock_split_1HV_resized)
		"connect_2":
			if not _cont.is_connected("resized", _on_dock_split_1HV_resized):
				__c._setup_signal.connect_resized(_cont, _on_dock_split_1HV_resized)

		"disconnect_3":
			if _cont.is_connected("resized", _on_dock_split_2HV_resized):
				_cont.disconnect("resized", _on_dock_split_2HV_resized)
		"connect_3":
			if not _cont.is_connected("resized", _on_dock_split_2HV_resized):
				__c._setup_signal.connect_resized(_cont, _on_dock_split_2HV_resized)

#endregion
################################################################################

##:: saveload
################################################################################
#region saveload_split_offset

func _save_param_split_offset(_key: String, _split_offset: int) -> void:
	__c._saveload_conf._save_parameter_type_value(_self_index, _key, _split_offset)

func _loading_container_data(_load_data: Dictionary, _key_index: String) -> void:
	__c._saveload_handler._loading_container_data_handler(_load_data, _key_index)

#endregion
################################################################################




