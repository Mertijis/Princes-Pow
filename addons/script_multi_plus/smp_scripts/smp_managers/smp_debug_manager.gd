@tool
class_name SMPDebugManager
extends Node


#region m_variables

@export var _debug_signal: bool = false

@export_group("Plugin")
@export var _plugin_enable: bool = false
@export var _get_window_layout: bool = false
@export var _settings_changed: bool = false
@export var _exit_tree_data: bool = false

@export_group("System")
@export var _event_log: bool = false
@export var _err_open_log: bool = false
@export var _save_data_log: bool = false
@export var _save_update: bool = false
@export var _load_enabled: bool = false
@export var _files_moved: bool = false
@export var _file_removed: bool = false
@export var _tab_changed: bool = false
@export var _node_order_tree: bool = false

@export_group("VBox_Notif")
@export var _child_entered_notif: bool = false
@export var _child_exiting_notif: bool = false
@export var _child_ordering_notif: bool = false
@export var _is_connected_notif: bool = false
@export var _focus_entered_notif: bool = false
@export var _swaping_data_notif: bool = false
@export var _current_dicts: bool = false
@export var _script_opened: bool = false
@export var _script_closed: bool = false

#endregion

var __end: String = "[/color]"
var __icolor: String = "[color=orange]"
var __bcolor: String = "[color=medium_orchid]"
var __ncolor: String = "[color=pale_green]"
var __scolor: String = "[color=khaki]"


##:: log_name
################################################################################
#region _debug_onready_dict

@onready var _log_names_dict: Dictionary = {
		"enable_plugin": _plugin_enable,
		"get_window_layout": _get_window_layout,
		"on_settings_changed": _settings_changed,
		"exit_tree_data": _exit_tree_data,

		"files_moved": _files_moved,
		"file_removed": _file_removed,
		"on_tab_changed": _tab_changed,

		"script_opened_pre": _script_opened,
		"script_opened"    : _script_opened,
		"script_closed"    : _script_closed,
		"on_script_closed" : _script_closed,
		"on_script_closed_save_data": _script_closed,

		"child_entered"    : _child_entered_notif,
		"child_exiting"    : _child_exiting_notif,
		"child_orderin"    : _child_ordering_notif,
		"ce__connected"    : _is_connected_notif,
		"focus_entered"    : _focus_entered_notif,

		"current_dict"     : _current_dicts,
		"swap_data_pre"    : _swaping_data_notif,
		"swap_data_post"   : _swaping_data_notif,

		"entered_node"    : _node_order_tree,
		"exiting_node"    : _node_order_tree,
		"order_changed"   : _node_order_tree,
		"close_1"         : _node_order_tree,
		"close_2"         : _node_order_tree,

		"ev_close"           : _event_log,
		"ev_close_all"       : _event_log,
		"ev_close_other_tabs": _event_log,
		"ev_close_docs"      : _event_log,
		"title"              : _event_log,
}

#endregion
################################################################################


##:: utility
################################################################################
#region _color_rich
#print_rich("[color=deep_sky_blue][b]Hello world![/b][/color] aaa")

func _rpre(_color_str: String) -> String:
	return "[color=%s][b]" %_color_str

func _rend() -> String:
	return "[/b][/color]"

#endregion
################################################################################
#region _debug_options

func _debug_get_keyword_lines(_node: Object, _keyword: String) -> int:
	var _sc: GDScript = _node.get_script()
	var _code: String = _sc.source_code
	var _lines: PackedStringArray = _code.split("\n")
	var _keyword_lines: int = 0

	for i: int in range(_lines.size()):
		if _keyword in _lines[i]:
			_keyword_lines = i + 1
			return _keyword_lines
	return _keyword_lines

func _get_script_name(_node: Object) -> String:
	return _node.get_script().get_global_name()

func _get_script_name_res(_name: String) -> String:
	return _name

#endregion
################################################################################


##:: type
################################################################################
#region _debug_process

func _debug_log(
	_type: String, _self: Object, _log: String, _variant: Variant, _line: String
	) -> void:
	var _class_name: String = _get_script_name(_self)
	var _line_num: int = _debug_get_keyword_lines(_self, _line)
	match _type:
		"pri":
			var _rich_clor: String = "[color=deep_sky_blue]"
			print_rich("%sline > %s%s [%s]:: %s%s:%s %s" % [
				_rich_clor, _line_num, __end, _class_name,
				_rich_clor, _log, __end, _variant
				])
		"war":
			push_warning("line > %s [%s]:: %s: %s" % [_line_num, _class_name, _log, _variant])
		"err":
			push_error("line > %s [%s]:: %s: %s" % [_line_num, _class_name, _log, _variant])
		"rich":
			var _rich_num: String = "[color=coral]"
			var _rich_clor: String = "[color=medium_turquoise]"
			print_rich("%sline > %s[/color] [%s]:: %s%s[/color]: %s" % [
				_rich_num, _line_num, _class_name, _rich_clor, _log, _variant
				])
		_:
			push_warning("line > 132 [SMEDebugManager] Not match name: %s" % _type)

#endregion
################################################################################
#region _debug_process_resource

func _debug_log_res(
	_type: String, _self: Resource, _name: String, _log: String, _variant: Variant, _line: String
	) -> void:
	var _class_name: String = _get_script_name_res(_name)
	var _line_num: int = _debug_get_keyword_lines(_self, _line)
	match _type:
		"pri":
			print("line > %s [%s]:: %s: %s" % [_line_num, _class_name, _log, _variant])
		"war":
			push_warning("line > %s [%s]:: %s: %s" % [_line_num, _class_name, _log, _variant])
		"err":
			push_error("line > %s [%s]:: %s: %s" % [_line_num, _class_name, _log, _variant])
		"rich":
			var _rich_num: String = "[color=coral]"
			var _rich_clor: String = "[color=medium_turquoise]"
			print_rich("%sline > %s[/color] [%s]:: %s%s[/color]: %s" % [
				_rich_num, _line_num, _class_name, _rich_clor, _log, _variant
				])
		_:
			push_warning("line > 157 [SMEDebugManager] Not match name: %s" % _type)

#endregion
################################################################################


##:: log
################################################################################
#region _debug_params

""" file_moved_removed """
func _files_moved_debug_log(
	_type: String, _self: Resource, _name: String, _log: String, _vari: Variant, _line: String
	) -> void:
	if _files_moved:
		_debug_log_res(_type, _self, _name, _log, _vari, _line)

func _file_removed_debug_log(
	_type: String, _self: Resource, _name: String, _log: String, _vari: Variant, _line: String
	) -> void:
	if _file_removed:
		_debug_log_res(_type, _self, _name, _log, _vari, _line)

""" saveload """
func _load_enabled_debug_log(
	_type: String, _self: Resource, _name: String, _log: String, _vari: Variant, _line: String
	) -> void:
	if _load_enabled:
		_debug_log_res(_type, _self, _name, _log, _vari, _line)

func _save_data_debug_log(
	_type: String, _self: Resource, _name: String, _log: String, _vari: Variant, _line: String
	) -> void:
	if _save_data_log:
		_debug_log_res(_type, _self, _name, _log, _vari, _line)

func _save_update_log(
	_type: String, _self: Resource, _name: String, _log: String, _vari: Variant, _line: String
	) -> void:
	if _save_update:
		_debug_log_res(_type, _self, _name, _log, _vari, _line)

""" err_open """
func _err_open_debug_log(
	_type: String, _self: Node, _log: String, _vari: Variant, _line: String) -> void:
	if _err_open_log:
		_debug_log(_type, _self, _log, _vari, _line)

#endregion
################################################################################
#region _debug_log_signal

func _log_signal(
	_type: String, _self: Object, _log: String, _vari: Variant, _line: String
	) -> void:
	if not _debug_signal:
		return

	var _has := _log_names_dict.has(_log)
	if not _has:
		_debug_log("war", _self, _log, "", _line)
		return

	var _log_call: bool = _log_names_dict[_log]
	if _log_call:
		_debug_log(_type, _self, _log, _vari, _line)

#endregion
################################################################################


##:: __notif
################################################################################
#region debug__notif

func _on_sc_closed_notif(_tindex: int, _sc: String) -> Array:
	var _notif: Array = [
		"tab_idx: %s%s%s" % [__icolor, _tindex, __end],
		"closed_script_name: %s%s%s" % [__scolor, _sc.get_file(), __end],
		"closed_script_path: %s%s%s" % [__scolor, _sc, __end],
	]
	return _notif

func _dock_split_data_notif(_dict: Dictionary) -> Array:
	var _notif: Array = [
		"dock_split_1H: %s%s%s"   % [__icolor, _dict.get("dock_split_1H", null), __end],
		"dock_split_1HD: %s%s%s"  % [__icolor, _dict.get("dock_split_1HD", null), __end],
		"dock_split_1V: %s%s%s"   % [__icolor, _dict.get("dock_split_1V", null), __end],
		"dock_split_1VD: %s%s%s"  % [__icolor, _dict.get("dock_split_1VD", null), __end],
		"dock_split_2H: %s%s%s"   % [__icolor, _dict.get("dock_split_2H", null), __end],
		"dock_split_2HD: %s%s%s"  % [__icolor, _dict.get("dock_split_2HD", null), __end],
		"dock_split_2V: %s%s%s"   % [__icolor, _dict.get("dock_split_2V", null), __end],
		"dock_split_2VD: %s%s%s"  % [__icolor, _dict.get("dock_split_2VD", null), __end],
	]
	return _notif

################################################################################

func _boot_notif(
	_sel_num: int, _sel_text: String, _load_tab: int, _sc_name: String
	) -> Array:
	var __notif: Array = [
		"curr_tab: %s%s%s" % [__icolor, _sel_num, __end],
		"%s%s%s" % [__ncolor, _sel_text, __end],
		"load_tab: %s%s%s" % [__icolor, _load_tab, __end],
		"%s%s%s" % [__ncolor, _sc_name, __end],
		]
	return __notif

func _enabled_notif(_num: int, _list: Array) -> Array:
	var __notif: Array = [
		"load_tab: %s%s%s" % [__icolor, _num, __end],
		"list: %s%s%s" % [__ncolor, _list, __end],
		]
	return __notif

func _loading_data_notif(_dict: Dictionary) -> Array:
	var _notif: Array = [
		"focus_idx: %s%s%s"   % [__icolor, _dict.get("focus_index", -1), __end],
		"tab_idx: %s%s%s"     % [__icolor, _dict.get("tab_index", -1), __end],
		"sc_name: %s%s%s"     % [__scolor, _dict.get("sc_name", ""), __end],
		"script_path: %s%s%s" % [__scolor, _dict.get("script_path", ""), __end],
		"uid_path: %s%s%s"    % [__scolor, _dict.get("uid_path", ""), __end],
	]
	return _notif

func _saving_data_notif(_dict: Dictionary) -> Array:
	var _notif: Array = [
		"add_button: %s%s%s"  % [__bcolor, _dict.get("add_button", null), __end],
		"minimap: %s%s%s"     % [__bcolor, _dict.get("minimap", null), __end],
		"vert_button: %s%s%s" % [__bcolor, _dict.get("vert_button", null), __end],
		"wrap_mode: %s%s%s"   % [__bcolor, _dict.get("wrap_mode", null), __end],
		"focus_idx: %s%s%s"   % [__icolor, _dict.get("focus_index", -1), __end],
		"tab_idx: %s%s%s"     % [__icolor, _dict.get("tab_index", -1), __end],
		"sc_name: %s%s%s"     % [__scolor, _dict.get("sc_name", []), __end],
		"script_path: %s%s%s" % [__scolor, _dict.get("script_path", ""), __end],
		"uid_path: %s%s%s"    % [__scolor, _dict.get("uid_path", ""), __end],
	]
	return _notif

################################################################################

func _data_dict_arr_notif(dict: Dictionary) -> Array:
	var _notif: Array = [
		"focus_idx: %s%s%s"   % [__icolor, dict.get("focus_index", -1), __end],
		"tab_idx: %s%s%s"     % [__icolor, dict.get("tab_index", -1), __end],
		"root: %s%s%s"        % [__ncolor, dict.get("root", null), __end],
		"parent: %s%s%s"      % [__ncolor, dict.get("parent", null), __end],
		"code_edit: %s%s%s"   % [__ncolor, dict.get("code_edit", null), __end],
		"rich_text: %s%s%s"   % [__ncolor, dict.get("rich_text", null), __end],
		"findbar: %s%s%s"     % [__ncolor, dict.get("findbar", null), __end],
		"cedit: %s%s%s"       % [__ncolor, dict.get("cedit", null), __end],
		"sc_name: %s%s%s"     % [__scolor, dict.get("sc_name", ""), __end],
		"script_path: %s%s%s" % [__scolor, dict.get("script_path", ""), __end],
		"uid_path: %s%s%s"    % [__scolor, dict.get("uid_path", ""), __end],
	]
	return _notif

#endregion
################################################################################
















