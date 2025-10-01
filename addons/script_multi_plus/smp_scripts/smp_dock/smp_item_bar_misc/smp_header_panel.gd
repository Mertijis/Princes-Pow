@tool
class_name SMPHeaderPanel
extends Panel


""" class """
var __c: SMPClassManagers
var _plugin: ScriptMultiPlusPlugin
var _dock_main: ScriptMultiPlusDock


################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is ScriptMultiPlusPlugin:
				_plugin = item
			if item is ScriptMultiPlusDock:
				_dock_main = item
			elif item is SMPClassManagers:
				__c = item

		_set_ready_status()

#endregion
################################################################################
#region _set_ready

func _set_ready_status() -> void:
	__c._setup_settings._set_theme_override_header_panel(self)

#endregion
################################################################################




