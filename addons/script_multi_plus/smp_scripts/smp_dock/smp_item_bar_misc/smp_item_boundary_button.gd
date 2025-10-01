@tool
class_name SMPItemBoundaryButton
extends SMPItemButtonParent


var _button_index: int = 0

var _is_boundary_button: bool = false


################################################################################
#region signal_ready

func _set_ready_signal() -> void:
	__c._setup_signal.connect_button_pressed(self, _on_button_pressed)

#endregion
################################################################################
#region set_ready

func _set_ready_status() -> void:
	_button_index = _get_button_index()
	_set_icon_tooltip("hide")

func _get_button_index() -> int:
	var _owner: SMPDockContainer = __c._setup_utility._find_parent_dock_container(self)
	return _owner.container_index

#endregion
################################################################################
#region set_status

func _set_icon_tooltip(_type: String) -> void:
	match _type:
		"show":
			self.self_modulate.a = 1.0
			_is_boundary_button = true
		"hide":
			self.self_modulate.a = 0.5
			_is_boundary_button = false

	self.tooltip_text = __c._setup_settings._tooltip_dict["boundary"]
	self.icon = __c._setup_settings._icon_dict["boundary"]

	__c._setup_settings._set_icon_alignment(self, "center")
	__c._setup_settings._set_icon_custom_min_size_x(
		self, __c._setup_settings._min_size_x["boundary"]
		)

#endregion
################################################################################
#region setget_button_status

func _is_minimap_pressed() -> void:
	_is_boundary_button = not _is_boundary_button

func get_button_status() -> bool:
	return _is_boundary_button

#endregion
################################################################################
#region handle_button

func _set_boundary_handle(_key_index: int = -1, _load_set: bool = false) -> void:
	if _key_index != -1:
		_button_index = _key_index
		_is_boundary_button = _load_set
		_set_boundary_icon_handle()

	match _button_index:
		1:
			_dock_main._mcontainer_1._set_wrap_mode(_is_boundary_button)
		2:
			_dock_main._mcontainer_2._set_wrap_mode(_is_boundary_button)
		3:
			_dock_main._mcontainer_3._set_wrap_mode(_is_boundary_button)

func _set_boundary_icon_handle() -> void:
	if not _is_boundary_button:
		_set_icon_tooltip("hide")
	else:
		_set_icon_tooltip("show")

#endregion
################################################################################
#region signal On_connect

func _on_button_pressed() -> void:
	_is_minimap_pressed()
	_set_boundary_icon_handle()
	_set_boundary_handle()

#endregion
################################################################################





