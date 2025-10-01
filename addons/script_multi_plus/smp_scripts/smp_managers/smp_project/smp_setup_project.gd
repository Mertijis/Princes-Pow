@tool
class_name ScriptMultiPlusProject
extends Resource


var _settings = ProjectSettings
var _setup_settings: ScriptMultiPlusSettings
var _settings_key: ScriptMultiPlusProjectInputKeys


""" project_settings """
const ADDON_PATH: String = "addons/script_multi_plus/"

const SETTINGS_SHORTCUTS := "%s/shortcuts/code_edit_shotcut_keys" % ADDON_PATH

const SETTINGS_SCROLL_PAST_END := "%s/code_edit/text_scroll_past_end_of_file" % ADDON_PATH
const SETTINGS_SCROLL_CARET_CENTER := "%s/code_edit/center_caret_on_scroll" % ADDON_PATH
const SETTINGS_TEXT_MULTIPLY := "%s/code_edit/caret_scroll_multiply" % ADDON_PATH
const SETTINGS_POPUP_RECENT_SIZE := "%s/code_edit/popup_recent_max_size" % ADDON_PATH
const SETTINGS_FOCUS_FLASH_TYPE := "%s/code_edit/focus_flash_type" % ADDON_PATH

const SETTINGS_TEXT_FIND_COLOR := "%s/find/text_find_color" % ADDON_PATH
const SETTINGS_TEXT_WORD_COLOR := "%s/find/text_word_color" % ADDON_PATH
const SETTINGS_TEXT_FIND_ALPHA := "%s/find/text_find_alpha" % ADDON_PATH
const SETTINGS_TEXT_WORD_ALPHA := "%s/find/text_word_alpha" % ADDON_PATH

const SETTINGS_POPUP_PANEL_SIZE := "%s/finder_panel/popup_panel_size" % ADDON_PATH
const SETTINGS_POPUP_FIND_COLUMN_SIZE := "%s/finder_panel/popup_find_column_size" % ADDON_PATH
const SETTINGS_POPUP_TEXT_SIZE := "%s/finder_panel/popup_text_size" % ADDON_PATH
const SETTINGS_POPUP_FOLDER_NAME := "%s/finder_panel/popup_folder_name" % ADDON_PATH
var _folder_names: Array[String] = ["Scripts"]


var _shortcut: Shortcut
var _inputkey_dict: Dictionary
var _store_inputkey_dict: Dictionary



##:: setup_shortcut
################################################################################
#region setup_class

func _set_class() -> void:
	_shortcut = Shortcut.new()
	_settings_key = ScriptMultiPlusProjectInputKeys.new()
	_shortcut.resource_name = _settings_key._shortcut_label

func _get_inputkey_status(_has: int) -> void:
	var _key: Shortcut = _settings.get_setting(SETTINGS_SHORTCUTS)
	for item in _key.events:
		if _store_inputkey_dict.has(item.resource_name):
			var _name: String = item.resource_name
			_inputkey_dict[_name] = item
			if _has == 1:
				_store_inputkey_dict[_name] = item
			#print("name: ", _name)

#endregion
################################################################################


##:: shortcut_regist
################################################################################
#region set_shortcut_res

func _setup_shortcut_key(_has: String = "") -> Shortcut:
	for stat in _settings_key._shortcut_key_maps:
		var _inputkey := InputEventKey.new()
		#_inputkey.resource_path = stat["name"] #-> broken project
		_inputkey.resource_name = stat["label"]
		_inputkey.pressed = stat["pressed"]
		_inputkey.keycode = stat["keycode"]
		_inputkey.alt_pressed = stat["alt_pressed"]
		_inputkey.shift_pressed = stat["shift_pressed"]
		_inputkey.device = 0

		var _os_name: String = OS.get_name()

		match _os_name:
			"Windows", "Linux":
				_inputkey.ctrl_pressed = stat["ctrl_pressed"]
			"macOS":
				_inputkey.meta_pressed = stat["meta_pressed"]
			_:
				_inputkey.ctrl_pressed = stat["ctrl_pressed"]

		_inputkey.echo = stat["echo"]
		_shortcut.events.push_back(_inputkey)
		_store_inputkey_dict[stat["label"]] = _inputkey

	return _shortcut

func _setup_shortcut_name() -> Dictionary:
	for stat in _settings_key._shortcut_key_maps:
		_store_inputkey_dict[stat["label"]] = null
	return _store_inputkey_dict

#endregion
################################################################################
#region update_inputkeys_data

func _update_shortcut_remapping(_input_data: Dictionary) -> Shortcut:
	var _remap_shortcut := Shortcut.new()
	for key: String in _input_data:
		var _inputkey := InputEventKey.new()
		var _stat: InputEventKey = _input_data[key]

		_inputkey.resource_name = key
		_inputkey.pressed = _stat.pressed
		_inputkey.keycode = _stat.keycode
		_inputkey.alt_pressed = _stat.alt_pressed
		_inputkey.shift_pressed = _stat.shift_pressed
		_inputkey.device = 0

		var _os_name: String = OS.get_name()

		match _os_name:
			"Windows", "Linux":
				_inputkey.ctrl_pressed = _stat.ctrl_pressed
			"macOS":
				_inputkey.meta_pressed = _stat.meta_pressed
			_:
				_inputkey.ctrl_pressed = _stat.ctrl_pressed

		_inputkey.echo = _stat.echo
		_remap_shortcut.events.push_back(_inputkey)
		_remap_shortcut.resource_name = _settings_key._shortcut_label
		_store_inputkey_dict[key] = _inputkey
		_inputkey_dict[key] = _inputkey

	return _remap_shortcut

#endregion
################################################################################


##:: handle
################################################################################
#region ps_set_handler

func _project_settings_handler() -> void:
	_set_class()
	_project_settings_scroll_past_end_of_file()
	_project_settings_center_caret_on_scroll()
	_project_settings_move_caret_multiply()
	_project_settings_popup_recent_size()
	_project_settings_focus_flash_type()

	_project_settings_text_word_alpha()
	_project_settings_text_word_color()
	_project_settings_text_find_alpha()
	_project_settings_text_find_color()

	_project_settings_folder_names()
	_project_settings_popup_find_column_size()
	_project_settings_popup_text_size()
	_project_settings_popup_panel_size()
	_project_settings_code_edit_shortcuts()

#endregion
################################################################################


##:: code_edit
################################################################################
#region ps_caret_multiply

func _get_caret_scroll_multiply() -> int:
	return _settings.get_setting(SETTINGS_TEXT_MULTIPLY)

func _project_settings_move_caret_multiply() -> void:
	if not _settings.has_setting(SETTINGS_TEXT_MULTIPLY):
		_settings.set_setting(SETTINGS_TEXT_MULTIPLY, 2)

	_settings.add_property_info({
		"name": SETTINGS_TEXT_MULTIPLY,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "1,32,1",
	})

#endregion
################################################################################
#region ps_past_end_of_file

func _get_scroll_past_end_of_file() -> int:
	return _settings.get_setting(SETTINGS_SCROLL_PAST_END)

func _project_settings_scroll_past_end_of_file() -> void:
	if not _settings.has_setting(SETTINGS_SCROLL_PAST_END):
		_settings.set_setting(SETTINGS_SCROLL_PAST_END, true)

	_settings.add_property_info({
		"name": SETTINGS_SCROLL_PAST_END,
		"type": TYPE_BOOL,
	})

#endregion
################################################################################
#region ps_center_caret_on_scroll

func _get_center_caret_on_scroll() -> int:
	return _settings.get_setting(SETTINGS_SCROLL_CARET_CENTER)

func _project_settings_center_caret_on_scroll() -> void:
	if not _settings.has_setting(SETTINGS_SCROLL_CARET_CENTER):
		_settings.set_setting(SETTINGS_SCROLL_CARET_CENTER, true)

	_settings.add_property_info({
		"name": SETTINGS_SCROLL_CARET_CENTER,
		"type": TYPE_BOOL,
	})

#endregion
################################################################################
#region ps_menu_recent_size

func _get_popup_recent_size() -> int:
	return _settings.get_setting(SETTINGS_POPUP_RECENT_SIZE)

func _project_settings_popup_recent_size() -> void:
	if not _settings.has_setting(SETTINGS_POPUP_RECENT_SIZE):
		_settings.set_setting(SETTINGS_POPUP_RECENT_SIZE, 8)

	_settings.add_property_info({
		"name": SETTINGS_POPUP_RECENT_SIZE,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "2,16,1",
	})

#endregion
################################################################################
#region ps_focus_flash_type

func _get_focus_flash_type() -> int:
	return _settings.get_setting(SETTINGS_FOCUS_FLASH_TYPE)

func _project_settings_focus_flash_type() -> void:
	if not _settings.has_setting(SETTINGS_FOCUS_FLASH_TYPE):
		_settings.set_setting(SETTINGS_FOCUS_FLASH_TYPE, 1)

	_settings.add_property_info({
		"name": SETTINGS_FOCUS_FLASH_TYPE,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,2,1",
	})

#endregion
################################################################################


##:: text_find_color
################################################################################
#region ps_text_find_word_color

func _get_text_word_color() -> Color:
	return _settings.get_setting(SETTINGS_TEXT_WORD_COLOR)

func _project_settings_text_word_color() -> void:
	if not _settings.has_setting(SETTINGS_TEXT_WORD_COLOR):
		var _color: Color = _setup_settings._color_dict["numb_color"]
		_settings.set_setting(SETTINGS_TEXT_WORD_COLOR, _color)

	_settings.add_property_info({
		"name": SETTINGS_TEXT_WORD_COLOR,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	})

#endregion
################################################################################
#region ps_text_find_color

func _get_text_find_color() -> Color:
	return _settings.get_setting(SETTINGS_TEXT_FIND_COLOR)

func _project_settings_text_find_color() -> void:
	if not _settings.has_setting(SETTINGS_TEXT_FIND_COLOR):
		var _color: Color = _setup_settings._color_dict["func_color"]
		_settings.set_setting(SETTINGS_TEXT_FIND_COLOR, _color)

	_settings.add_property_info({
		"name": SETTINGS_TEXT_FIND_COLOR,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	})

#endregion
################################################################################
#region ps_text_find_alpha

func _get_text_find_alpha() -> float:
	if _settings.has_setting(SETTINGS_TEXT_FIND_ALPHA):
		return _settings.get_setting(SETTINGS_TEXT_FIND_ALPHA)
	return 0.2

func _project_settings_text_find_alpha() -> void:
	if not _settings.has_setting(SETTINGS_TEXT_FIND_ALPHA):
		_settings.set_setting(SETTINGS_TEXT_FIND_ALPHA, 0.2)

	_settings.add_property_info({
		"name": SETTINGS_TEXT_FIND_ALPHA,
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0,1.0,0.01",
	})

#endregion
################################################################################
#region ps_text_find_word_alpha

func _get_text_word_alpha() -> float:
	if _settings.has_setting(SETTINGS_TEXT_WORD_ALPHA):
		return _settings.get_setting(SETTINGS_TEXT_WORD_ALPHA)
	return 0.12

func _project_settings_text_word_alpha() -> void:
	if not _settings.has_setting(SETTINGS_TEXT_WORD_ALPHA):
		_settings.set_setting(SETTINGS_TEXT_WORD_ALPHA, 0.12)

	_settings.add_property_info({
		"name": SETTINGS_TEXT_WORD_ALPHA,
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0,1.0,0.01",
	})

#endregion
################################################################################


##:: finder_panel
################################################################################
#region ps_folder_names

func _get_project_settings_folder_names() -> Array[String]:
	if _settings.has_setting(SETTINGS_POPUP_FOLDER_NAME):
		return _settings.get_setting(SETTINGS_POPUP_FOLDER_NAME)
	return []

func _project_settings_folder_names() -> void:
	if not _settings.has_setting(SETTINGS_POPUP_FOLDER_NAME):
		_settings.set_setting(SETTINGS_POPUP_FOLDER_NAME, _folder_names)

	_settings.add_property_info({
		"name": SETTINGS_POPUP_FOLDER_NAME,
		"type": TYPE_ARRAY,
	})

#endregion
################################################################################
#region ps_popup_panel_size

func _get_popup_panel_size() -> Vector2:
	return _settings.get_setting(SETTINGS_POPUP_PANEL_SIZE)

func _project_settings_popup_panel_size() -> void:
	if not _settings.has_setting(SETTINGS_POPUP_PANEL_SIZE):
		_settings.set_setting(SETTINGS_POPUP_PANEL_SIZE, Vector2(0.56, 0.61))

	_settings.add_property_info({
		"name": SETTINGS_POPUP_PANEL_SIZE,
		"type": TYPE_VECTOR2,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.25,0.88,0.01",
	})

#endregion
################################################################################
#region ps_popup_find_column_size

func _get_popup_find_column_size() -> int:
	return _settings.get_setting(SETTINGS_POPUP_FIND_COLUMN_SIZE)

func _project_settings_popup_find_column_size() -> void:
	if not _settings.has_setting(SETTINGS_POPUP_FIND_COLUMN_SIZE):
		_settings.set_setting(SETTINGS_POPUP_FIND_COLUMN_SIZE, 5)

	_settings.add_property_info({
		"name": SETTINGS_POPUP_FIND_COLUMN_SIZE,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "2,8,1",
	})

#endregion
################################################################################
#region ps_popup_text_size

func _get_popup_text_size() -> int:
	return _settings.get_setting(SETTINGS_POPUP_TEXT_SIZE)

func _project_settings_popup_text_size() -> void:
	if not _settings.has_setting(SETTINGS_POPUP_TEXT_SIZE):
		_settings.set_setting(SETTINGS_POPUP_TEXT_SIZE, 13)

	_settings.add_property_info({
		"name": SETTINGS_POPUP_TEXT_SIZE,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "8,32,1",
	})

#endregion
################################################################################


##:: shortcut
################################################################################
#region ps_shortcuts

func _get_project_settings_code_edit_shortcuts() -> Shortcut:
	return _settings.get_setting(SETTINGS_SHORTCUTS)

func _set_project_settings_code_edit_shortcuts() -> void:
	var _remap_data: Shortcut = _update_shortcut_remapping(_store_inputkey_dict)
	_settings.set_setting(SETTINGS_SHORTCUTS, _remap_data)
	_settings.save()

func _project_settings_code_edit_shortcuts() -> void:
	if not _settings.has_setting(SETTINGS_SHORTCUTS):
		_shortcut =  _setup_shortcut_key()
		_settings.set_setting(SETTINGS_SHORTCUTS, _shortcut)
		_get_inputkey_status(0)
	else:
		_store_inputkey_dict = _setup_shortcut_name()
		_get_inputkey_status(1)

#endregion
################################################################################
