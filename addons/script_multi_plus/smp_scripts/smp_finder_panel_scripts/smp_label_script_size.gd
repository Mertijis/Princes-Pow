@tool
class_name SMPLabelScriptSize
extends MarginContainer


""" class """
var __c: SMPClassManagers

@onready var _icon_texture_size: TextureRect = %IconTextureSize
@onready var _label_script_size: Label = %LabelScriptSize


################################################################################
#region setup_class

func _setup_class(_setup_arr: Array) -> void:
	if not _setup_arr.is_empty():
		for item in _setup_arr:
			if item is SMPClassManagers:
				__c = item

	_set_texture()
	_set_label_name(9999)

#endregion
################################################################################

func _set_texture() -> void:
	__c._setup_settings._set_icon_texture(_icon_texture_size, "tex", "int")

func _set_label_name(_num: int) -> void:
	_label_script_size.text = str(_num)

