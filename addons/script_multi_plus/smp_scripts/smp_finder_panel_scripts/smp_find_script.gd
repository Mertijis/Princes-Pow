@tool
class_name SMPFindScript
extends Node


""" class """
var __c: SMPClassManagers
var _find_popup_panel: SMPFindPopupPanel
var _editor_fs_dir: SMPFilesystemDir


var _all_script: PackedStringArray
var _word_candidates: Array[Dictionary]

var _cur_search_id: int = 0
var _store_text: String = ""


################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item
			elif item is SMPFindPopupPanel:
				_find_popup_panel = item
			elif item is SMPFilesystemDir:
				_editor_fs_dir = item

#endregion
################################################################################
#region _set_regex_word

func _get_words_from_script(_path_arr: PackedStringArray) -> void:
	_all_script = _path_arr
	var _word_set: Dictionary = {}

	var _regex := RegEx.new()
	_regex.compile(r"\b[_a-zA-Z][_a-zA-Z0-9_]*\b")

	_word_candidates.clear()

	for _path: String in _path_arr:
		for result in _regex.search_all(_path.get_file()):
			var word := result.get_string()

			if _word_set.has(word):
				continue
			var _normalized := word.replace("_", "").to_lower()

			_word_set[word] = true

			_word_candidates.push_back({
				"original": word + ".gd",
				"normalized": _normalized,
			})

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
#region _set_init_spawn

func _get_movable_count(_match_words: PackedStringArray) -> int:
	var _item_count: int = _match_words.size()
	var _set_max_column: int = __c._setup_project._get_popup_find_column_size()
	var _min_row_size: int = __c._setup_settings._finder_script_row_min_size
	var _result_quanty: int = _min_row_size * _set_max_column
	var _row_size: int

	if _item_count <= _result_quanty:
		_row_size = _min_row_size
	else:
		if _find_popup_panel._current_folder_dict["index"] != -1:
			_row_size = _find_popup_panel._get_column_equal_size(_match_words)
		else:
			_row_size = _find_popup_panel._store_row_size
	return _row_size

func _set_default_script_list() -> void:
	if _find_popup_panel._current_folder_dict["index"] == -1:
		_all_script = _editor_fs_dir._sc_path_arr
	var _movable_count: int = _get_movable_count(_all_script)
	_find_popup_panel._set_init_position_names.call_deferred(_movable_count)

#endregion
################################################################################
#region _signal On_connect_text_changed

func _find_on_text_submitted(_new_text: String) -> void:
	_find_popup_panel._line_edit_find.text_changed.emit(_new_text)

func _find_on_text_changed(_new_text: String) -> void:
	_store_text = _new_text

	if _editor_fs_dir._is_load_button:
		return

	_cur_search_id += 1
	var _this_search_id = _cur_search_id

	if _new_text == "":
		call_deferred_thread_group("_set_default_script_list")
		_find_popup_panel._button_text_empty._set_visible_text_empty(false)
		_cur_search_id = 0
	else:
		_find_popup_panel._button_text_empty._set_visible_text_empty(true)
		var _match_words: PackedStringArray = _search_word_candidates(_new_text)
		call_deferred_thread_group("_move_reparent_process", _match_words, _this_search_id)
		#print("match: ", _match_words.size())

func _move_reparent_process(_match_words: PackedStringArray, _search_id: int) -> void:
	var _location_idx: int = 0
	var _visible_count: int = 0
	var _processed: int = 0
	var _movable_count: int = _get_movable_count(_match_words)
	#print("movable: ", _movable_count)

	var _base_container := _find_popup_panel._script_containers[0]._item_container
	for container: SMPContainerScript in _find_popup_panel._script_containers:
		for child in container._item_container.get_children():
			child._set_visible_status(false)
			child.reparent(_base_container)

	for child in _base_container.get_children():
		if _search_id != _cur_search_id:
			break

		if is_instance_valid(child):
			if _match_words.has(child._store_name):
				if _visible_count >= _movable_count:
					_location_idx += 1
					_visible_count = 0

				var _new_parent := _find_popup_panel._script_containers[_location_idx]._item_container
				child.reparent(_new_parent)
				child._set_visible_status(true)
				_visible_count += 1

				_processed += 1
				if _processed % 15 == 0:
					await get_tree().process_frame
					if _search_id != _cur_search_id:
						break

	_find_popup_panel._label_script_size._set_label_name(_match_words.size())

#endregion
################################################################################
#region _signal On_connect_gui_input

func _on_gui_input(_event: InputEvent) -> void:
	if _event is InputEventKey:
		if _event.pressed and _event.keycode == KEY_TAB:
			_find_popup_panel._find_sc_container_first_item.call_deferred("forward")

		elif _event.pressed and _event.keycode == KEY_ENTER:
			if _find_popup_panel._line_edit_find.has_focus():
				_find_popup_panel._set_line_edit_status("select")

		elif _event.pressed and _event.ctrl_pressed and _event.keycode == KEY_F:
			_find_popup_panel._set_line_edit_status("all")

		elif _select_key_alt_pressed(_event, KEY_J, KEY_LEFT):
			if _find_popup_panel._current_folder_dict["index"] != -1:
				_find_popup_panel._selected_folder_grab_focus.call_deferred()
				return
			_find_popup_panel._find_folder_container_first_item.call_deferred("forward")

		elif _select_key_alt_pressed(_event, KEY_K, KEY_DOWN):
			_find_popup_panel._find_sc_container_first_item.call_deferred("forward")

#endregion
################################################################################

func _select_key_alt_pressed( _event: InputEventKey, _key_1: Key, _key_2: Key,) -> bool:
	if _event.pressed and _event.alt_pressed and _event.keycode == _key_1 or \
		_event.pressed and _event.keycode == _key_2:
		return true
	return false



#region shortcut

