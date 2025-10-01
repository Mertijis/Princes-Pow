@tool
class_name SMPContainerScript
extends MarginContainer


@onready var _item_container: VBoxContainer = %ItemContainer


func _set_add_child_script(_child: Node) -> void:
	_item_container.add_child(_child)

