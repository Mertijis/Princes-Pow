@tool
class_name SMPClassManagers
extends Resource


""" config_file """
var _godot_conf: ConfigFile

""" setup_class """
var _debug_manager: SMPDebugManager
var _plugin: ScriptMultiPlusPlugin

""" setup """
var _setup_lazy: ScriptMultiPlusLazy
var _setup_signal: ScriptMultiPlusSignal
var _setup_project: ScriptMultiPlusProject
var _setup_settings: ScriptMultiPlusSettings
var _setup_utility: ScriptMultiPlusUtility

""" saveload """
var _saveload_conf: SMPSaveLoadConf
var _saveload_filesystem: SMPFileSystem
var _saveload_manager: SMPSaveLoadManager
var _saveload_handler: SMPSaveLoadHandler

""" find """
var _find_word_tools: SMPFindWordTools
var _find_word_script_tools: SMPFindScriptTools

""" other """
var _event_dock_input: SMPDockInput
var _split_utility: SMPSplitUtility
var _scroll_caret_calc: SMPScrollCaretCalc
var _item_exp_setter: SMPItemExpandSetter
var _dock_order_trees: SMPDockOrderTrees
var _doc_helper: SMPDocumentHelper

var _setup_arr: Array


################################################################################
#region _setup_lazy

func _get_setup_lazy(_setup_lazy: ScriptMultiPlusLazy) -> ScriptMultiPlusLazy:
	if _setup_lazy == null:
		_setup_lazy = ScriptMultiPlusLazy.new()
	return _setup_lazy

func _setup_init_lazy() -> void:
	_setup_lazy = _get_setup_lazy(_setup_lazy)
	_setup_utility = _setup_lazy._get_setup_utility(_setup_utility)
	_setup_signal = _setup_lazy._get_setup_signal(_setup_signal)
	_setup_project = _setup_lazy._get_setup_project(_setup_project)
	_setup_settings = _setup_lazy._get_setup_settings(_setup_settings)

	_saveload_conf = _setup_lazy._get_saveload_conf(_saveload_conf)
	_saveload_handler = _setup_lazy._get_saveload_handler(_saveload_handler)
	_saveload_manager = _setup_lazy._get_saveload_manager(_saveload_manager)
	_saveload_filesystem = _setup_lazy._get_saveload_filesystem(_saveload_filesystem)

	_split_utility = _setup_lazy._get_split_utility(_split_utility)
	_scroll_caret_calc = _setup_lazy._get_scroll_caret_calc(_scroll_caret_calc)
	_dock_order_trees = _setup_lazy._get_order_trees(_dock_order_trees)
	_doc_helper = _setup_lazy._get_doc_helper(_doc_helper)

	_find_word_tools = _setup_lazy._get_find_word_tools(_find_word_tools)
	_find_word_script_tools = _setup_lazy._get_find_word_script_tools(_find_word_script_tools)


	if _event_dock_input == null:
		_event_dock_input = SMPDockInput.new()

	if _item_exp_setter == null:
		_item_exp_setter = SMPItemExpandSetter.new()


	_setup_project._setup_settings = _setup_settings
	_setup_init_project_settings()
	_setup_project._project_settings_handler()
	_load_config()

	_setup_arr = [
		self, _setup_signal, _setup_project, _setup_settings,
		_saveload_conf, _saveload_filesystem, _saveload_handler,
		_split_utility, _item_exp_setter,
		_find_word_script_tools, _find_word_tools,
		_scroll_caret_calc, _event_dock_input, _dock_order_trees,
		_doc_helper,
		_godot_conf,
	]

func _setup_init_project_settings() -> void:
	_saveload_manager._saveload_config_file()
	_saveload_manager._init_create_file()

#endregion
################################################################################
#region create_conf_file

func _load_config() -> void:
	if _godot_conf == null:
		var _conf = ConfigFile.new()

		var _conf_path: String = "%s%s%s" % [
			_saveload_manager._root_path,
			_saveload_manager._get_saved_file_name(),
			_saveload_manager._extension,
		]

		_setup_settings._conf_path = _conf_path
		_setup_settings._section = _saveload_manager._section
		_saveload_conf._save_key = _setup_settings._save_key_name

		var _error = _conf.load(_conf_path)
		if _error != OK:
			push_warning("[ScriptMultiEditorPlugin]: Not exists conf file::%s" % _conf_path)
			return
		_godot_conf = _conf
		#prints("conf: ", _conf_path, _godot_conf)

#endregion
################################################################################



