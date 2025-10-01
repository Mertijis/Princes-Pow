@tool
class_name SMPItemMinimapButton
extends SMPItemButtonParent


var _button_index: int = 0

var _is_minimap_button: bool = false


################################################################################
#region signal_ready

func _set_ready_signal() -> void:
	__c._setup_signal.connect_button_pressed(self, _on_button_pressed)

#endregion
################################################################################
#region set_ready

func _set_ready_status() -> void:
	_button_index = _get_button_index()
	_set_icon_tooltip("show")

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
			_is_minimap_button = true
		"hide":
			self.self_modulate.a = 0.5
			_is_minimap_button = false

	self.tooltip_text = __c._setup_settings._tooltip_dict["minimap"]
	self.icon = __c._setup_settings._icon_dict["minimap"]

	__c._setup_settings._set_icon_alignment(self, "right")
	__c._setup_settings._set_icon_custom_min_size_x(
		self, __c._setup_settings._min_size_x["minimap"]
		)

#endregion
################################################################################
#region setget_button_status

func _is_minimap_pressed() -> void:
	_is_minimap_button = not _is_minimap_button

func get_button_status() -> bool:
	return _is_minimap_button

#endregion
################################################################################
#region handle_button

func _set_minimap_handle(_key_index: int = -1, _load_set: bool = false) -> void:
	if _key_index != -1:
		_button_index = _key_index
		_is_minimap_button = _load_set
		_set_minimap_icon_handle()

	match _button_index:
		1:
			_dock_main._mcontainer_1._set_minimap_draw(_is_minimap_button)
		2:
			_dock_main._mcontainer_2._set_minimap_draw(_is_minimap_button)
		3:
			_dock_main._mcontainer_3._set_minimap_draw(_is_minimap_button)

func _set_minimap_icon_handle() -> void:
	if not _is_minimap_button:
		_set_icon_tooltip("hide")
	else:
		_set_icon_tooltip("show")

#endregion
################################################################################
#region signal On_connect

func _on_button_pressed() -> void:
	_is_minimap_pressed()
	_set_minimap_icon_handle()
	_set_minimap_handle()

#endregion
################################################################################



