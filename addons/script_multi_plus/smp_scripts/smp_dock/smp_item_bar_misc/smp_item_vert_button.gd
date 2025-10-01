@tool
class_name SMPItemVertButton
extends SMPItemButtonParent


var _button_index: int = 0

var _is_vert_button: bool = false


################################################################################
#region set_ready

func _set_ready_status() -> void:
	__c._setup_settings._set_icon_alignment(self, "center")
	__c._setup_settings._set_icon_custom_min_size_x(
		self, __c._setup_settings._min_size_x["vert"]
		)
	_button_index = _get_button_index()
	_set_icon_text("hori")
	_set_visible_icon()

func _set_ready_signal() -> void:
	__c._setup_signal.connect_button_pressed(self, _on_button_pressed)

func _get_button_index() -> int:
	var _owner: SMPDockContainer = __c._setup_utility._find_parent_dock_container(self)
	return _owner.container_index

#endregion
################################################################################
#region set_status

func _set_icon_text(_type: String) -> void:
	match _type:
		"hori":
			self.icon = __c._setup_settings._icon_dict["hori"]
			self.text = __c._setup_settings._text_dict["null"]
		"vert":
			self.icon = __c._setup_settings._icon_dict["vert"]
			self.text = __c._setup_settings._text_dict["null"]
	self.tooltip_text = __c._setup_settings._tooltip_dict["vert"]

func _is_vert_pressed() -> void:
	_is_vert_button = not _is_vert_button

func _get_button_state() -> bool:
	return _is_vert_button

func _set_visible_icon() -> void:
	match _button_index:
		1:
			_dock_main._mcontainer_1._dock_item_bar._item_vertical_button.set_visible(false)
		2:
			_dock_main._mcontainer_2._dock_item_bar._item_vertical_button.set_visible(true)
		3:
			_dock_main._mcontainer_3._dock_item_bar._item_vertical_button.set_visible(true)

#endregion
################################################################################
#region handle_button_state

func _set_vert_icon_handle() -> void:
	if not _is_vert_button:
		_set_icon_text("hori")
	else:
		_set_icon_text("vert")

#endregion
################################################################################
#region handle_button

func _set_vert_handle(_key_index: int = -1, _load_set: bool = false) -> void:
	if _key_index != -1:
		_button_index = _key_index
		_is_vert_button = _load_set
		_set_vert_icon_handle()
		_change_grab_areas()

	match _button_index:
		2:
			_dock_main._mcontainer_2._set_vert_state(_is_vert_button)
		3:
			_dock_main._mcontainer_3._set_vert_state(_is_vert_button)

	_dock_main._change_vertical_status(_is_vert_button, _button_index)

func _change_grab_areas() -> void:
	var _vert2: bool = _dock_main._mcontainer_2._get_vert_button_state()
	var _vert3: bool = _dock_main._mcontainer_3._get_vert_button_state()
	var _thick_size: int = __c._setup_settings._grab_thick_size

	__c._setup_settings._set_theme_override_min_grab_thick(_dock_main._dock_split, _thick_size, _vert2)
	__c._setup_settings._set_theme_override_min_grab_thick(_dock_main._dock_split2, _thick_size, _vert3)

#endregion
################################################################################
#region signal On_connect

func _on_button_pressed() -> void:
	_is_vert_pressed()
	_set_vert_icon_handle()
	_set_vert_handle()
	_change_grab_areas()

	#prints("on_vert_button: ", _button_index, _is_vert_button)

#endregion
################################################################################





