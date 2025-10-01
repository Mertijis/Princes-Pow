@tool
class_name SMPSaveLoadManager
extends Resource


var _section: String = "script_multi_plus"


""" project_settings """
const ADDON_PATH: String = "addons/script_multi_plus/"

const SETTINGS_NAME = "%s/data/script_multi_plus_data" % ADDON_PATH
const CONFIG_FILE_DATA: String = "ScriptMultiPlusData"
var _root_path: String = "res://"
var _extension: String = ".cfg"

var _settings := ProjectSettings

""" save_data """
var _data: Dictionary
var _save_path: String
var _curr_region_names: Array[String]

var _class_name: String
var _is_loading_data: bool = true


var _saveload_error: Dictionary = {
	"not_found": "Not found save data.",
	"load_file": "Failed loading save data. Error loading file: %d.",
	"load_invalid": "Failed loading save data. File contains invalid data.",
	"save_file": "Failed saving save data. Error writing file: %d."
}


####################################################################################################
#region _color_rich
#print_rich("[color=deep_sky_blue][b]Hello world![/b][/color] aaa")

func _rpre(_color_str: String) -> String:
	return "[color=%s][b]" %_color_str

func _rend() -> String:
	return "[/b][/color]"

#endregion
####################################################################################################
#region _debug_options

func _get_script_name() -> String:
	return get_script().get_global_name()

func _debug_get_keyword_lines(_sc: GDScript, _keyword: String) -> int:
	var _code: String = _sc.source_code
	var _lines: PackedStringArray = _code.split("\n")
	var _keyword_lines: int = 0

	for i: int in range(_lines.size()):
		if _keyword in _lines[i]:
			_keyword_lines = i + 1
	return _keyword_lines

func _debug_print(_debug_type: String, _line_num: String, _error: String) -> void:
	var _line: int = _debug_get_keyword_lines(get_script(), _line_num)
	match _debug_type:
		"print":
			print("line::%s > [%s] %s" % [_line, _get_script_name(), _error])
		"warning":
			push_warning("line::%s > [%s] %s" % [_line, _get_script_name(), _error])
		"error":
			push_error("line::%s > [%s] %s" % [_line, _get_script_name(), _error])

#endregion
####################################################################################################
#region _project_settings

func _saveload_config_file() -> void:
	if not _settings.has_setting(SETTINGS_NAME):
		_settings.set_setting(SETTINGS_NAME, CONFIG_FILE_DATA)
	else:
		_save_path = _settings.get_setting(SETTINGS_NAME)

	_settings.add_property_info({
		"name": SETTINGS_NAME,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_SAVE_FILE
	})

	_settings.save()

#endregion
####################################################################################################
#region _init_create_file

func _init_create_file() -> void:
	if not _is_exists_save_data():
		if not _settings.has_setting(SETTINGS_NAME):
			_settings.set_setting(SETTINGS_NAME, CONFIG_FILE_DATA)

		if _settings.get_setting(SETTINGS_NAME) == "":
			_settings.set_setting(SETTINGS_NAME, CONFIG_FILE_DATA)

		if not _save_path.is_empty():
			_save_path = _settings.get_setting(SETTINGS_NAME)

		_save_path = _get_saved_file_name()

		var _file_path: String = "%s%s%s" % [_root_path, _save_path, _extension]

		var _conf := ConfigFile.new()
		_conf.set_value(_section, "", "")

		_conf.save(_file_path)

#endregion
####################################################################################################
#region _get_save_file_name

func _get_saved_file_name() -> String:
	var _temp_name: String
	if _save_path.is_empty():
		_temp_name = _settings.get_setting(SETTINGS_NAME) as String

		if _temp_name.contains("res://") or _temp_name.contains("."):
			var _temp: String = _temp_name.get_file().get_basename()
			return _temp
		return _temp_name

	else:
		if _save_path.contains("res://") or _save_path.contains("."):
			_temp_name = _save_path.get_file().get_basename()
			return _temp_name
		return _save_path
	return ""

#endregion
####################################################################################################
#region _is_exists

func _is_exists_save_data() -> bool:
	_save_path = _get_saved_file_name()
	var _file_path: String = "%s%s%s" % [_root_path, _save_path, _extension]
	if FileAccess.file_exists(_file_path):
		return true
	return false

#endregion
####################################################################################################















