@tool
class_name SMPFindWordTools
extends Node


var _debug_manager: SMPDebugManager
var _setup_project: ScriptMultiPlusProject
var _setup_settings: ScriptMultiPlusSettings

var _colors: Dictionary = {}

var _word_lines: PackedInt32Array


##:: setup
################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is ScriptMultiPlusProject:
				_setup_project = item
			elif item is ScriptMultiPlusSettings:
				_setup_settings = item
			elif item is SMPDebugManager:
				_debug_manager = item

	_set_colors()

#endregion
################################################################################
#region _set_status

func _init_word_lines() -> void:
	_word_lines.clear()

func _set_colors() -> void:
	_colors = {
		"def": _setup_settings._color_dict["transparent"],
		"reig": _setup_settings._color_dict["reig_color"],
		"mark": _setup_settings._color_dict["mark_color"],
		"numb": _setup_settings._color_dict["numb_color"],
	}

#endregion
################################################################################


##:: find_handle_word
################################################################################
#region _text_find_word_handler

func _find_word_changed_color(_code_edit: CodeEdit) -> void:
	var _has_words: PackedInt32Array = _find_store_line(_code_edit)

	_find_init_color(_code_edit)
	_word_lines = _has_words

	_find_set_color(_code_edit, _has_words)
	_code_edit.select_word_under_caret()
	#prints("words: ", _has_words)

#endregion
################################################################################
#region _text_find_word_options

func _find_init_color(_code_edit: CodeEdit) -> void:
	if _code_edit == null:
		return
	var _line_count: int = _code_edit.get_line_count()

	for i: int in range(_line_count):
		var _line_text: String = _code_edit.get_line(i)

		if _code_edit.get_line_background_color(i) != _colors["mark"]:
			_code_edit.set_line_background_color(i, _colors["def"])

		if _line_text.contains("#region") and not _line_text.contains("\t"):
			if _code_edit.is_line_folded(i):
				_code_edit.set_line_background_color(i, _colors["reig"])


func _find_store_line(_code_edit: CodeEdit) -> PackedInt32Array:
	var _line_count: int = _code_edit.get_line_count()
	var _word_get: String = _code_edit.get_word_under_caret()
	var _has_words: PackedInt32Array

	for i: int in range(_line_count):
		var _line_text: String = _code_edit.get_line(i)
		if _line_text.contains(_word_get):
			if not _has_words.has(i):
				_has_words.push_back(i)
	return _has_words


func _find_set_color(_code_edit: CodeEdit, _has_words: PackedInt32Array) -> void:
	var _find_color: Color = _setup_project._get_text_word_color()
	_find_color.a = _setup_project._get_text_word_alpha()
	if not _has_words.is_empty():
		for i: int in _has_words:
			if _code_edit.get_line_background_color(i) != _colors["mark"]:
				_code_edit.set_line_background_color(i, _find_color)

#endregion
################################################################################


##:: jump_caret
################################################################################
#region _jump_selected_word

func _jump_previous_for_selected_word(_code_edit: CodeEdit) -> void:
	var _line: int = _code_edit.get_caret_line()
	var _column: int = _code_edit.get_caret_column()
	_code_edit.deselect()

	var _amount_dir: int = -1
	var _next_visible: int = _code_edit.get_next_visible_line_offset_from(_line, _amount_dir)
	_line += _amount_dir * _next_visible

	if not _word_lines.is_empty():
		var _first_line: int = _word_lines[0] - 1

		if _word_lines[0] == _code_edit.get_caret_line():
			_code_edit.set_caret_line(_word_lines[-1])
			return

		for num: int in range(_line, _first_line, -1):
			if _word_lines[0] == _line:
				_code_edit.set_caret_line(num)
				return
			elif _word_lines.has(num):
				_code_edit.set_caret_line(num)
				return

func _jump_next_for_selected_word(_code_edit: CodeEdit) -> void:
	var _line: int = _code_edit.get_caret_line()
	var _column: int = _code_edit.get_caret_column()
	_code_edit.deselect()

	var _amount_dir: int = 1
	var _next_visible: int = _code_edit.get_next_visible_line_offset_from(_line, _amount_dir)
	_line += _amount_dir * _next_visible

	if not _word_lines.is_empty():
		var _last_line: int = _word_lines[-1] + 1

		if _word_lines[-1] == _code_edit.get_caret_line():
			_code_edit.set_caret_line(_word_lines[0])
			return

		for num: int in range(_line, _last_line):
			if _word_lines[-1] == _line:
				_code_edit.set_caret_line(num)
				return
			elif _word_lines.has(num):
				_code_edit.set_caret_line(num)
				return

#endregion
################################################################################
#region _find_exist_region

func _find_exist_is_region_line(_code_edit: CodeEdit) -> bool:
	var _line: int = _code_edit.get_caret_line()
	var _line_text: String = _code_edit.get_line(_line)
	var _select_word: String = _code_edit.get_word_under_caret()
	if _line_text.contains("#region") and not _line_text.contains("\t"):
		if _select_word == "region":
			return true
	return false

func _find_set_region_line(_code_edit: CodeEdit) -> void:
	var _line: int = _code_edit.get_caret_line()
	var _line_text: String = _code_edit.get_line(_line)
	if _line_text.contains("#region"):
		if not _code_edit.is_line_folded(_line):
			_code_edit.fold_line(_line)
		else:
			_code_edit.unfold_line(_line)

#endregion
################################################################################

