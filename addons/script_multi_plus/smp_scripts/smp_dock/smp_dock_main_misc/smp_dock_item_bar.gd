@tool
class_name SMPDockItemBar
extends MarginContainer


@export var _bar_dock_index: int = 0

var _item_bar_arr: Array


@onready var _item_header_panel: SMPHeaderPanel = %ItemHeaderPanel

@onready var _item_hbox: HBoxContainer = %ItemBarHBox
@onready var _item_expand_button: SMPItemExpandButton = %ItemExpandButton
@onready var _item_vertical_button: SMPItemVertButton = %ItemVerticalButton
@onready var _item_rich_name: SMPItemRichName = %ItemRichName
@onready var _item_boundary_button: SMPItemBoundaryButton = %ItemBoundaryButton
@onready var _item_minimap_button: SMPItemMinimapButton = %ItemMinimapButton
@onready var _item_add_button: SMPItemAddButton = %ItemAddButton

@onready var _item_recent_menu: SMPRecentMenuButton = %ItemRecentMenu
@onready var _item_dir_access: SMPItemDirAcess = %ItemDirAccess


################################################################################
#region set_array_node

func _set_class(_setup_arr: Array) -> void:
	_item_bar_arr = _get_item_arr()
	for item in _item_bar_arr:
		item._setup_class(_setup_arr)
	_item_header_panel._setup_class(_setup_arr)
	_item_header_panel.custom_minimum_size.y = 25

func _get_item_arr() -> Array:
	return [
		_item_expand_button,
		_item_vertical_button,
		_item_rich_name,
		_item_boundary_button,
		_item_minimap_button,
		_item_add_button,
		_item_recent_menu,
		_item_dir_access,
	]

#endregion
################################################################################


