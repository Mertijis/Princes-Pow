@tool
class_name SMPItemExpandSetter
extends Resource


""" class """
var __c: SMPClassManagers
var _debug_manager: SMPDebugManager
var _plugin: ScriptMultiPlusPlugin
var _dock_main: ScriptMultiPlusDock


var _container1: SMPDockContainer
var _container2: SMPDockContainer
var _container3: SMPDockContainer


################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is ScriptMultiPlusPlugin:
				_plugin = item
			elif item is ScriptMultiPlusDock:
				_dock_main = item
			elif item is SMPDebugManager:
				_debug_manager = item
			elif item is SMPClassManagers:
				__c = item

	_set_container()

func _set_container() -> void:
	_container1 = _dock_main._get_focus_mcontainer(1)
	_container2 = _dock_main._get_focus_mcontainer(2)
	_container3 = _dock_main._get_focus_mcontainer(3)

#endregion
################################################################################
##:: utility
#region is_visible_minimap_state

func _is_visible_drawing_minimap(_cont: SMPDockContainer, _findex: int, _active: bool) -> void:
	var _section: String = __c._setup_settings._section
	var _indexs: Array[String] = __c._saveload_conf._indexs
	for key: String in _indexs:
		var _key_int: int = key.to_int()
		if _key_int == _findex:
			if __c._saveload_conf._has_check_index_data(key):
				var _data: Dictionary = __c._godot_conf.get_value(_section, key)
				var _mbool: bool = _data[_findex].get("minimap", true)
				var _mcont := _dock_main._get_focus_mcontainer(_findex)
				_mcont._set_minimap_draw(_mbool)

#endregion
################################################################################


##:: focus
################################################################################
#region focus_expand

func _focus_selected(_findex: int, _s: Array = [0, 0, 0]) -> void:
	var _mcont := _dock_main._get_focus_mcontainer(_findex)
	var _def: Array = [1, 1, 1]
	var _is_D: String = ""

	if _dock_main._is_distract_button:
		_is_D = "D"

	_set_focus_expand_selected(_def)
	_set_focus_code_edit(_findex)

	if _mcont._code_edit != null:
		if not _mcont._code_edit.has_focus():
			_set_defualt_unfocus_expand()
			_state_container_3(_is_D)
		else:
			_selected_process_active(_mcont, _is_D, _def, _s)

	elif _mcont._te_cedit != null:
		if _findex != _mcont.container_index:
			if not _mcont._code_edit.has_focus():
				_set_defualt_unfocus_expand()
				_state_container_3(_is_D)
			else:
				_mcont._te_cedit.grab_focus()
				_selected_process_active(_mcont, _is_D, _def, _s)
		else:
			_set_select_unfocus_expand(_findex)
			_mcont._te_cedit.grab_focus()
			_selected_process_active(_mcont, _is_D, _def, _s)

	elif _mcont._rich_text != null:
		if _findex != _mcont.container_index:
			if not _mcont._code_edit.has_focus():
				_set_defualt_unfocus_expand()
				_state_container_3(_is_D)
			else:
				_mcont._rich_text.grab_focus()
				_selected_process_active(_mcont, _is_D, _def, _s)
		else:
			_set_select_unfocus_expand(_findex)
			_mcont._rich_text.grab_focus()
			_selected_process_active(_mcont, _is_D, _def, _s)


func _selected_process_active(
	_mcont: SMPDockContainer, _is_D: String, _def: Array, _s: Array
	) -> void:
	if not _mcont._get_expand_button_state():
		_mcont.emit_expand_button_pressed()
		_set_focus_expand_selected(_s)
		_change_expand_split_offset("set", _is_D, _s)
	else:
		_mcont.emit_expand_button_pressed()
		_set_focus_expand_selected(_def)
		_change_expand_split_offset("ret", _is_D, _s)

func _set_focus_expand_selected(_active: Array) -> void:
	_set_focus_expand_selected_cont(_container1, 1, _active[0])
	_set_focus_expand_selected_cont(_container2, 2, _active[1])
	_set_focus_expand_selected_cont(_container3, 3, _active[2])

func _set_focus_expand_selected_cont(_cont: SMPDockContainer, _fcont: int, _active: int) -> void:
	if _cont._code_edit != null:
		_set_focus_expand_match(_cont, _fcont, _active as bool, "script")
	elif _cont._rich_text != null:
		_set_focus_expand_match(_cont, _fcont, _active as bool, "rich")
	elif _cont._te_cedit != null:
		_set_focus_expand_match(_cont, _fcont, _active as bool, "te")
	elif _cont._code_edit == null or \
		_cont._rich_text == null or \
		_cont._te_cedit == null:
		_set_focus_expand_match(_cont, _fcont, _active as bool, "null")

#endregion
################################################################################
#region focus_type

func _set_focus_expand_match(
	_cont: SMPDockContainer, _findex: int, _active: bool, _type: String
	) -> void:
	_cont._code_edit = _cont._get_vbox_child_ce()

	match _type:
		"script":
			var _hbox := _cont._get_code_edit_hbox()
			if _hbox != null:
				_hbox.set_visible(_active)
			_is_visible_drawing_minimap(_cont, _findex, _active)
			if _cont._code_edit != null:
				if _cont._code_edit.is_drawing_minimap():
					_cont._code_edit.minimap_draw = _active
			_cont._dock_item_bar.set_visible(_active)

		"rich":
			var _rt := _cont._get_vbox_child_rich_text()
			var _fb := _cont._get_vbox_child_findbar()
			_cont._dock_item_bar.set_visible(_active)
			if _rt != null:
				_rt.set_visible(_active)
			if _fb != null:
				if _fb.is_visible():
					_fb.set_visible(_active)

		"te":
			_cont._dock_item_bar.set_visible(_active)
		"null":
			_cont._dock_item_bar.set_visible(_active)


func _set_defualt_unfocus_expand() -> void:
	var _mconts := _dock_main._get_mcontainer_arr()
	for cont: SMPDockContainer in _mconts:
		cont._set_expand_button(false)
		cont._dock_item_bar._item_expand_button._set_expand_handle()
		cont._dock_item_bar._item_expand_button._set_expand_icon_handle()

func _set_select_unfocus_expand(_findex: int) -> void:
	var _mconts := _dock_main._get_mcontainer_arr()
	for cont: SMPDockContainer in _mconts:
		if _findex != cont.container_index:
			cont._set_expand_button(false)
			cont._dock_item_bar._item_expand_button._set_expand_handle()
			cont._dock_item_bar._item_expand_button._set_expand_icon_handle()

#endregion
################################################################################
##:: focus_change
#region focus_change_set_return

func _change_expand_split_offset(_type: String, _is_D: String, _fnum: Array = [0, 0, 0]) -> void:
	var _vert2: bool = _dock_main._mcontainer_2._get_vert_button_state()
	var _vert3: bool = _dock_main._mcontainer_3._get_vert_button_state()
	var _data := __c._saveload_conf._get_save_data("index_0")

	if _type == "set":
		match _fnum:
			[1, 0, 0]:
				_dock_main._dock_split.split_offset = 9999
			[0, 1, 0]:
				if not _vert2:
					_dock_main._dock_split.split_offset = 0
					_dock_main._dock_split2.split_offset = 9999
				else:
					_dock_main._dock_split.split_offset = -9999
					_dock_main._dock_split2.split_offset = 9999
			[0, 0, 1]:
				if not _vert2 and not _vert3 or \
					not _vert2 and _vert3:

					_dock_main._dock_split.split_offset = 0
					_dock_main._dock_split2.split_offset = -9999

				elif _vert2 and not _vert3 or \
					_vert2 and _vert3:

					_dock_main._dock_split.split_offset = -9999
					_dock_main._dock_split2.split_offset = -9999

	elif _type == "ret":
		if _data.get(0, {}) == null:
			return
		match _fnum:
			[1, 0, 0]:
				if not _vert2:
					_dock_main._dock_split.split_offset = _data[0].get("dock_split_1H%s" % _is_D, 0)
					if not _vert3:
						_dock_main._dock_split2.split_offset = _data[0].get("dock_split_2H%s" % _is_D, 0)
					else:
						_dock_main._dock_split2.split_offset = _data[0].get("dock_split_2V%s" % _is_D, 0)
				else:
					_dock_main._dock_split.split_offset = _data[0].get("dock_split_1V%s" % _is_D, 0)
					if not _vert3:
						_dock_main._dock_split2.split_offset = _data[0].get("dock_split_2H%s" % _is_D, 0)
					else:
						_dock_main._dock_split2.split_offset = _data[0].get("dock_split_2V%s" % _is_D, 0)

			[0, 1, 0]:
				if not _vert2:
					_dock_main._dock_split.split_offset = _data[0].get("dock_split_1H%s" % _is_D, 0)
					_dock_main._dock_split2.split_offset = _data[0].get("dock_split_2V%s" % _is_D, 0)
					if not _vert3:
						_dock_main._dock_split2.split_offset = _data[0].get("dock_split_2H%s" % _is_D, 0)
					else:
						_dock_main._dock_split2.split_offset = _data[0].get("dock_split_2V%s" % _is_D, 0)
				else:
					_dock_main._dock_split.split_offset = _data[0].get("dock_split_1V%s" % _is_D, 0)
					if not _vert3:
						_dock_main._dock_split2.split_offset = _data[0].get("dock_split_2H%s" % _is_D, 0)
					else:
						_dock_main._dock_split2.split_offset = _data[0].get("dock_split_2V%s" % _is_D, 0)

			[0, 0, 1]:
				_state_container_3(_is_D)


func _state_container_3(_is_D: String) -> void:
	var _vert2: bool = _dock_main._mcontainer_2._get_vert_button_state()
	var _vert3: bool = _dock_main._mcontainer_3._get_vert_button_state()
	var _data := __c._saveload_conf._get_save_data("index_0")

	if not _vert2 and not _vert3:
		_dock_main._dock_split.split_offset = _data[0].get("dock_split_1H%s" % _is_D, 0)
		_dock_main._dock_split2.split_offset = _data[0].get("dock_split_2H%s" % _is_D, 0)

	elif not _vert2 and _vert3:
		_dock_main._dock_split.split_offset = _data[0].get("dock_split_1H%s" % _is_D, 0)
		_dock_main._dock_split2.split_offset = _data[0].get("dock_split_2V%s" % _is_D, 0)

	elif _vert2 and not _vert3:
		_dock_main._dock_split.split_offset = _data[0].get("dock_split_1V%s" % _is_D, 0)
		_dock_main._dock_split2.split_offset = _data[0].get("dock_split_2H%s" % _is_D, 0)

	elif _vert2 and _vert3:
		_dock_main._dock_split.split_offset = _data[0].get("dock_split_1V%s" % _is_D, 0)
		_dock_main._dock_split2.split_offset = _data[0].get("dock_split_2V%s" % _is_D, 0)


func _set_focus_code_edit(_findex: int) -> void:
	var _mcont := _dock_main._get_focus_mcontainer(_findex)
	_dock_main._store_focus_index = _findex
	if _mcont._code_edit != null:
		_mcont._code_edit.grab_focus.call_deferred()

#endregion
################################################################################

