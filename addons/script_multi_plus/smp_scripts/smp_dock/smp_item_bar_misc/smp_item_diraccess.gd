@tool
class_name SMPItemDirAcess
extends SMPItemButtonParent


var _timer_clear: SMPTimerUtility

var _button_index: int = 0
var _event_button_index: int = 0


""" error_print """
var _dir_error_text: Dictionary = {
	"delete_completed" : "Deleted save file to trash. (%s)",
	"delete_container" : "Deleted containers data. (%s)",
	"not_exists"       : "Failed deleting save file does not exist. (%s)",
	"an_error_access"  : "An error occurred when trying to access the path. (%s)"
}

""" delete """
var _time: float = 0.0
var _border_0: float = 1.2
var _border_1: float = 2.4

var _is_deleting: bool = false
var _is_dir_button: bool = false

""" onready """
@onready var _tprog_bar: TextureProgressBar = %TextureProgressBar


##:: setup_sig
################################################################################
#region sig connect

func connect_file_button_down(
	_file_button: Button, _on_file_button_down: Callable
	) -> void:
	_file_button.button_down.connect(_on_file_button_down)

func connect_file_button_up(
	_file_button: Button, _on_file_button_up: Callable
	) -> void:
	_file_button.button_up.connect(_on_file_button_up)

func connect_gui_input(_control: Control, _on_gui_input: Callable) -> void:
	_control.gui_input.connect(_on_gui_input)

#endregion
################################################################################
#region signal_ready

func _set_ready_signal() -> void:
	connect_file_button_down(self, _on_file_button_down)
	connect_file_button_up(self, _on_file_button_up)
	connect_gui_input(self, _on_gui_input)

#endregion
################################################################################


##:: setup_set
################################################################################
#region set_ready

func _set_ready_status() -> void:
	_timer_clear = SMPTimerUtility.new(_dock_main)
	_button_index = _get_button_index()
	_set_icon_text()
	_set_visible_icon()
	_set_gradient_color(0)
	_set_self_status()

func _get_button_index() -> int:
	var _owner: SMPDockContainer = __c._setup_utility._find_parent_dock_container(self)
	return _owner.container_index

func _set_self_status() -> void:
	self.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	self.button_mask = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT

#endregion
################################################################################
#region set_status

func _set_icon_text() -> void:
	self.tooltip_text = __c._setup_settings._tooltip_dict["diraccess"]
	self.icon = __c._setup_settings._icon_dict["diraccess"]
	self.text = __c._setup_settings._text_dict["null"]
	__c._setup_settings._set_icon_custom_min_size_x(self, __c._setup_settings._min_size_x["diraccess"])
	__c._setup_settings._set_icon_alignment(self, "center")

func _set_visible_icon() -> void:
	match _button_index:
		1:
			_dock_main._mcontainer_1._dock_item_bar._item_dir_access.set_visible(true)
		2:
			_dock_main._mcontainer_2._dock_item_bar._item_dir_access.set_visible(false)
		3:
			_dock_main._mcontainer_3._dock_item_bar._item_dir_access.set_visible(false)

func _set_init_progress() -> void:
	set_process_internal(false)
	_event_button_index = 0
	_tprog_bar.value = 0
	_time = 0.0
	if _is_deleting:
		_timer_clear._set_timer_start_auto(1.2, 1, 1, _on_timeout_deleted)

func _set_is_dir_button(_active: bool) -> void:
	_is_dir_button = _active

func _get_button_state() -> bool:
	return _is_dir_button

func _set_dir_states(_active: bool) -> void:
	for cont in _dock_main._get_mcontainer_arr():
		cont._get_dir_button()._set_is_dir_button(_active)

func _clear_recent_menus() -> void:
	for cont in _dock_main._get_mcontainer_arr():
		cont._get_recent_menu_item()._pressed_menu_clear()

#endregion
################################################################################
#region set_color

func _set_gradient_color(_select: int) -> void:
	var _color_bar: Color
	var _color_icon: Color

	match _select:
		0:
			var _color_del_0: Array[Color] = __c._setup_settings._set_blend_inverted_color(0.06)
			var _color_icon_0: Array[Color] = __c._setup_settings._set_blend_inverted_color(0.063)
			_color_del_0[0].a = 0.5
			_color_bar = _color_del_0[0]
			_color_icon = _color_icon_0[1] * 1.3
		1:
			var _color_del_1: Array[Color] = __c._setup_settings._set_blend_inverted_color(0.915)
			var _color_icon_1: Array[Color] = __c._setup_settings._set_blend_inverted_color(0.022)
			_color_del_1[0].a = 0.5
			_color_bar = _color_del_1[0]
			_color_icon = _color_icon_1[1] * 1.3

	_tprog_bar.texture_progress.gradient.set_color(0, _color_bar)
	__c._setup_settings._set_theme_override_icon_color(self, "icon_pressed_color", _color_icon)

#endregion
################################################################################


##:: handle
################################################################################
#region _notification

func _notification(what: int) -> void:
	if what == NOTIFICATION_INTERNAL_PROCESS:
		_time += get_process_delta_time()
		_tprog_bar.value += get_process_delta_time()

		if _event_button_index == 1: # 1 = Mouse_left_click
			_tprog_bar.max_value = _border_0
			_set_gradient_color(0)

			if _time >= _border_0:
				_diraccess_file_delete(_event_button_index)
				_set_init_progress.call_deferred()

		elif _event_button_index == 2: # 2 = Mouse_right_click
			_tprog_bar.max_value = _border_1
			_set_gradient_color(1)

			if _time >= _border_1:
				_diraccess_file_delete(_event_button_index)
				_set_init_progress.call_deferred()

#endregion
################################################################################
#region handle_delete_save

func _clear_type_containers() -> void:
	if _is_deleting:
		return
	_is_deleting = true
	_diraccess_file_delete(1)
	_set_init_progress.call_deferred()

func _diraccess_file_delete(_eb_index: int) -> void:
	if _button_index != 1:
		return

	var _root_path: String = __c._saveload_manager._root_path
	var _extension: String = __c._saveload_manager._extension

	var _dir = DirAccess.open(_root_path)
	var _settings_path: String = __c._saveload_manager._get_saved_file_name()

	var _file_path: String = "%s%s%s" % [_root_path, _settings_path, _extension]

	if _file_path != "":
		if _dir.file_exists(_file_path):
			match _eb_index:
				1:
					_set_dir_states(true)
					_dock_main._dock_split2.set_visible(false)
					_plugin._exit_container_position()
					_plugin._clear_data_container_state("pre")

					await get_tree().process_frame
					__c._saveload_conf._clear_data_containers()
					_dock_main._deselect_sc_list.call_deferred()
					_dock_main._script_item_list.set_visible(false)

					_timer_clear._set_timer_start_auto(0.4, 1, 1, _on_timeout_clear)
					_debug_log(_file_path, "cont")
				2:
					_set_dir_states(true)
					_dock_main._dock_split2.set_visible(false)
					_plugin._exit_container_position()
					_plugin._clear_data_container_state("pre")

					await get_tree().process_frame
					_clear_recent_menus()
					_timer_clear._set_timer_start_auto(
						0.6, 1, 1, _on_timeout_clear_all.bind(_file_path)
						)
					_debug_log(_file_path, "comp")
					push_error("Please restart addon Script MultiPlus.")
		else:
			_debug_log(_file_path, "exs")
	else:
		_debug_log(_file_path, "error")

#endregion
################################################################################


##:: signal
################################################################################
#region sig on_connect

func _on_gui_input(_event: InputEvent) -> void:
	if _event is InputEventMouseButton:
		if not self.button_pressed:
			if _event.pressed and _event.button_index == MOUSE_BUTTON_LEFT:
				_event_button_index = 1

		if not self.button_pressed:
			if _event.pressed and _event.button_index == MOUSE_BUTTON_RIGHT:
				_event_button_index = 2

func _on_file_button_down() -> void:
	set_process_internal(true)

func _on_file_button_up() -> void:
	_set_dir_states(false)
	_set_init_progress.call_deferred()

#endregion
################################################################################
#region sig On_timeout

func _on_timeout_clear() -> void:
	_timer_clear._init_timeout_auto()
	_set_dir_states(false)
	_plugin._clear_data_container_state("post")
	__c._saveload_conf._clear_data_containers("")
	_dock_main._script_item_list.set_visible(true)

func _on_timeout_clear_all(_file_path: String) -> void:
	_timer_clear._init_timeout_auto()
	__c._saveload_conf._clear_data_containers("all")
	var _psettings = __c._setup_project._settings
	OS.move_to_trash(_psettings.globalize_path(_file_path))

func _on_timeout_deleted() -> void:
	_is_deleting = false

#endregion
################################################################################


##:: debug
################################################################################
#region debug_

func _debug_log(_file_path: String, _type: String) -> void:
	match _type:
		"comp":
			push_warning(_dir_error_text["delete_completed"] % _file_path)
		"cont":
			push_warning(_dir_error_text["delete_container"] % _file_path)
		"exs":
			push_error(_dir_error_text["not_exists"] % _file_path)
		"error":
			push_error(_dir_error_text["an_error_access"] % _file_path)

#endregion
################################################################################



