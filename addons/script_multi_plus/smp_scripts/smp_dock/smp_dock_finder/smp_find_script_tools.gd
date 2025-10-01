@tool
class_name SMPFindScriptTools
extends MarginContainer


var _container_index: int = -1

var __c: SMPClassManagers
var _dock_main: ScriptMultiPlusDock

var _curr_index: int
var _max_index: int

var _store_code_edit: CodeEdit
var _word_candidates: Array[Dictionary]
var _word_lines: PackedInt32Array

var _store_click_word: String:
	set(_value):
		_store_click_word = _value
	get:
		return _store_click_word

var _colors: Dictionary = {}


##:: setup
################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item
			elif item is ScriptMultiPlusDock:
				_dock_main = item

	_set_colors()

#endregion
################################################################################
#region _set_status

func _set_colors() -> void:
	_colors = {
		"def" : __c._setup_settings._color_dict["transparent"],
		"reig": __c._setup_settings._color_dict["reig_color"],
		"mark": __c._setup_settings._color_dict["mark_color"],
		"func": __c._setup_settings._color_dict["func_color"],
	}

#endregion
################################################################################


##:: word_candidate
################################################################################
#region _set_regex_word

func _get_words_from_script(_code_edit: CodeEdit) -> void:
	if _code_edit == null:
		return
	var _source_text: String = _code_edit.text
	var _word_set: Dictionary = {}

	var _regex := RegEx.new()
	_regex.compile(r"\b[_a-zA-Z][_a-zA-Z0-9_]*\b")

	_word_candidates.clear()

	for result in _regex.search_all(_source_text):
		var word := result.get_string()
		if _word_set.has(word):
			continue
		var _normalized := word.replace("_", "").to_lower()

		_word_set[word] = true

		_word_candidates.push_back({
			"original": word,
			"normalized": _normalized,
		})
	#print("word_keys: ", _word_candidates)

#endregion
################################################################################
#region _get_word_candidate

func _search_word_candidates(_new_text: String) -> PackedStringArray:
	if _new_text.length() == 0:
		return []

	var _search := _new_text.replace("_", "").to_lower()
	var _matches: PackedStringArray = []

	for word: Dictionary in _word_candidates:
		var _orig: String = word["original"]
		var _norm: String = word["normalized"]

		if _new_text == "_":
			if "_" in _orig:
				_matches.push_back(_orig)
		elif _search in _norm:
			_matches.push_back(_orig)

	return _matches

#endregion
################################################################################


##:: find_handle_code_editor
################################################################################
#region _text_find_word_handler

func _find_on_text_changed(_code_edit: CodeEdit, _new_text: String) -> void:
	var _falpha: float = __c._setup_project._get_text_find_alpha()
	if _falpha <= 0.0:
		return
	var _match_words: PackedStringArray = _search_word_candidates(_new_text)
	_find_result_changed_color(_code_edit, _match_words)

func _find_result_changed_color(_code_edit: CodeEdit, _match_words: PackedStringArray) -> void:
	var _has_words: PackedInt32Array = _find_store_line(_code_edit, _match_words)
	_find_init_color(_code_edit)
	_word_lines = _has_words
	_find_set_color(_code_edit, _has_words)

#endregion
################################################################################
#region _text_find_word_options

func _find_init_color(_code_edit: CodeEdit) -> void:
	var _line_count: int = _code_edit.get_line_count()

	for i: int in range(_line_count):
		var _line_text: String = _code_edit.get_line(i)

		if _code_edit.get_line_background_color(i) != _colors["mark"]:
			_code_edit.set_line_background_color(i, _colors["def"])

		if _line_text.contains("#region"):
			if _code_edit.is_line_folded(i):
				_code_edit.set_line_background_color(i, _colors["reig"])


func _find_store_line(_code_edit: CodeEdit, _matche_words: PackedStringArray) -> PackedInt32Array:
	var _line_count: int = _code_edit.get_line_count()
	var _has_line_words: PackedInt32Array

	for i: int in range(_line_count):
		var _line_text: String = _code_edit.get_line(i)
		for t: String in _matche_words:
			if _line_text.contains(t):
				if not _has_line_words.has(i):
					_has_line_words.push_back(i)
	return _has_line_words


func _find_set_color(_code_edit: CodeEdit, _has_words: PackedInt32Array) -> void:
	var _find_color: Color = __c._setup_project._get_text_find_color()
	_find_color.a = __c._setup_project._get_text_find_alpha()
	if not _has_words.is_empty():
		for i: int in _has_words:
			if _code_edit.get_line_background_color(i) != _colors["mark"]:
				_code_edit.set_line_background_color(i, _find_color)

#endregion
################################################################################

