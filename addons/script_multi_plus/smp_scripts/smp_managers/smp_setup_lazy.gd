@tool
class_name ScriptMultiPlusLazy
extends Resource


################################################################################
##:: setup
#region _lazy_init

func _get_setup_lazy(_setup_lazy: ScriptMultiPlusLazy) -> ScriptMultiPlusLazy:
	if _setup_lazy == null:
		_setup_lazy = ScriptMultiPlusLazy.new()
	return _setup_lazy

func _get_setup_project(_setup_project: ScriptMultiPlusProject) -> ScriptMultiPlusProject:
	if _setup_project == null:
		_setup_project = ScriptMultiPlusProject.new()
	return _setup_project

func _get_setup_settings(_setup_settings: ScriptMultiPlusSettings) -> ScriptMultiPlusSettings:
	if _setup_settings == null:
		_setup_settings = ScriptMultiPlusSettings.new()
	return _setup_settings

func _get_setup_signal(_setup_signal: ScriptMultiPlusSignal) -> ScriptMultiPlusSignal:
	if _setup_signal == null:
		_setup_signal = ScriptMultiPlusSignal.new()
	return _setup_signal

#endregion
################################################################################
##:: saveload
#region setup_saveload

func _get_saveload_conf(_setup_saveload_conf: SMPSaveLoadConf) -> SMPSaveLoadConf:
	if _setup_saveload_conf == null:
		_setup_saveload_conf = SMPSaveLoadConf.new()
	return _setup_saveload_conf

func _get_saveload_handler(_setup_saveload_handler: SMPSaveLoadHandler) -> SMPSaveLoadHandler:
	if _setup_saveload_handler == null:
		_setup_saveload_handler = SMPSaveLoadHandler.new()
	return _setup_saveload_handler

func _get_saveload_filesystem(_setup_saveload_filesystem: SMPFileSystem) -> SMPFileSystem:
	if _setup_saveload_filesystem == null:
		_setup_saveload_filesystem = SMPFileSystem.new()
	return _setup_saveload_filesystem

func _get_saveload_manager(_setup_saveload_manager: SMPSaveLoadManager) -> SMPSaveLoadManager:
	if _setup_saveload_manager == null:
		_setup_saveload_manager = SMPSaveLoadManager.new()
	return _setup_saveload_manager

#endregion
################################################################################
##:: other
#region setup_other

func _get_setup_utility(_setup_utility: ScriptMultiPlusUtility) -> ScriptMultiPlusUtility:
	if _setup_utility == null:
		_setup_utility = ScriptMultiPlusUtility.new()
	return _setup_utility

func _get_split_utility(_split_utility: SMPSplitUtility) -> SMPSplitUtility:
	if _split_utility == null:
		_split_utility = SMPSplitUtility.new()
	return _split_utility

func _get_find_word_script_tools(_find_word_script_tools: SMPFindScriptTools) -> SMPFindScriptTools:
	if _find_word_script_tools == null:
		_find_word_script_tools = SMPFindScriptTools.new()
	return _find_word_script_tools

func _get_find_word_tools(_find_word_tools: SMPFindWordTools) -> SMPFindWordTools:
	if _find_word_tools == null:
		_find_word_tools = SMPFindWordTools.new()
	return _find_word_tools

func _get_scroll_caret_calc(_scrool_caret_calc: SMPScrollCaretCalc) -> SMPScrollCaretCalc:
	if _scrool_caret_calc == null:
		_scrool_caret_calc = SMPScrollCaretCalc.new()
	return _scrool_caret_calc

func _get_order_trees(_dock_oreder_trees: SMPDockOrderTrees) -> SMPDockOrderTrees:
	if _dock_oreder_trees == null:
		_dock_oreder_trees = SMPDockOrderTrees.new()
	return _dock_oreder_trees

func _get_doc_helper(_doc_helper: SMPDocumentHelper) -> SMPDocumentHelper:
	if _doc_helper == null:
		_doc_helper = SMPDocumentHelper.new()
	return _doc_helper

#endregion
################################################################################






