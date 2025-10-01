@tool
class_name SMPButtonTextEmpty
extends Button


""" class """
var __c: SMPClassManagers
var _find_popup_panel: SMPFindPopupPanel


################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item
			elif item is SMPFindPopupPanel:
				_find_popup_panel = item

	_set_ready_signal()
	_set_visible_text_empty(false)

#endregion
################################################################################
#region _signal_connect

func _set_ready_signal() -> void:
	__c._setup_signal.connect_button_pressed(self, _on_button_pressed)

#endregion
################################################################################
#region _set_status

func _set_visible_text_empty(_active: bool) -> void:
	self.set_visible(_active)

#endregion
################################################################################
#region _signal On_connect

func _on_button_pressed() -> void:
	_set_visible_text_empty(false)
	_find_popup_panel._line_edit_find.text = ""
	_find_popup_panel._line_edit_find.text_changed.emit("")

#endregion
################################################################################
