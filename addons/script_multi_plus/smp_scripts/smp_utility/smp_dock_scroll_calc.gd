@tool
class_name SMPScrollCaretCalc
extends Node


var _setup_project: ScriptMultiPlusProject


################################################################################
##:: setup
#region _set_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is ScriptMultiPlusProject:
				_setup_project = item
				break

#endregion
################################################################################
##:: handle
#region scroll_calc

func _set_caret_scroll_multiply(_sign: int, _vscroll_value: float, _code_edit: CodeEdit) -> void:
	if _code_edit == null:
		return
	var _multiply: int = _setup_project._get_caret_scroll_multiply()
	var _line: int = _code_edit.get_caret_line()
	var _vscroll := _code_edit.get_v_scroll_bar()

	var _amount_dir: int = _sign * 1
	var _next_visible: int = _code_edit.get_next_visible_line_offset_from(_line, _amount_dir)

	_line += _sign * _next_visible

	var _adjust := _get_adjust_value(_multiply)
	var _calc: float = _vscroll_value + round(_sign * pow(_multiply, _adjust))

	_vscroll.value = _calc
	_code_edit.set_caret_line(_line + _sign * _multiply)

func _get_adjust_value(_step: int) -> float:
	var _min: float = 0.8
	var _max: float = 0.99
	var _offset: int = _get_offset_step(_step)

	var t := float(_step) / float(_step + _offset)
	var _eased := pow(t, 1.5)
	return lerp(_min, _max, _eased)


func _get_offset_step(_step: int) -> int:
	var _offset: int = 0
	if _step < 6:
		_offset = 3
		return _offset
	elif _step < 14:
		_offset = 2
		return _offset
	elif _step < 18:
		_offset = 1
		return _offset
	else:
		return 0
	return _offset

#endregion
################################################################################



