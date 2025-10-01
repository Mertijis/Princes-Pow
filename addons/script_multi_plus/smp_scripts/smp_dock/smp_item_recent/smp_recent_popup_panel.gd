@tool
class_name SMPRecentPopupPanel
extends PopupPanel



@onready var _vbox: VBoxContainer = %VBox


func _set_add_child(_node: Node) -> void:
	_vbox.add_child(_node)



