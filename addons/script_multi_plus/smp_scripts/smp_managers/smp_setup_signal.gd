@tool
class_name ScriptMultiPlusSignal
extends Resource


################################################################################
#region _signal connect

""" editor_plugin """
func connect_scene_saved(_plugin: EditorPlugin, _on_scene_saved: Callable) -> void:
	_plugin.scene_saved.connect(_on_scene_saved)

""" project_settings """
func connect_settings_changed(_ps: ProjectSettings, _on_settings_changed: Callable) -> void:
	_ps.settings_changed.connect(_on_settings_changed)

""" filesystem_dock """
func connect_files_moved(_filesystem_dock: FileSystemDock, _on_files_moved: Callable) -> void:
	_filesystem_dock.files_moved.connect(_on_files_moved)

func connect_files_removed(_filesystem_dock: FileSystemDock, _on_files_removed: Callable) -> void:
	_filesystem_dock.file_removed.connect(_on_files_removed)

""" script_editor """
func connect_editor_sc_changed(_sc_editor: ScriptEditor, _on_editor_sc_changed: Callable) -> void:
	_sc_editor.editor_script_changed.connect(_on_editor_sc_changed)

func connect_script_closed(_sc_editor: ScriptEditor, _on_script_closed: Callable) -> void:
	_sc_editor.script_close.connect(_on_script_closed)

func connect_goto_help(_sc_ebase: ScriptEditorBase, _on_goto_help: Callable) -> void:
	_sc_ebase.go_to_help.connect(_on_goto_help)

""" resized """
func connect_resized(_control: Control, _on_resized: Callable) -> void:
	_control.resized.connect(_on_resized)

""" button """
func connect_button_pressed(_button: Button, _on_button_pressed: Callable) -> void:
	_button.pressed.connect(_on_button_pressed)

func connect_button_toggled(_button: Button, _on_button_toggled: Callable) -> void:
	_button.toggled.connect(_on_button_toggled)

func connect_button_down(_button: Button, _on_button_down: Callable) -> void:
	_button.button_down.connect(_on_button_down)

func connect_button_up(_button: Button, _on_button_up: Callable) -> void:
	_button.button_up.connect(_on_button_up)

""" item_list """
func connect_item_selected(_item_list: ItemList, _on_item_selected: Callable) -> void:
	_item_list.item_selected.connect(_on_item_selected)

func connect_item_clicked(_item_list: ItemList, _on_item_clicked: Callable) -> void:
	_item_list.item_clicked.connect(_on_item_clicked)

################################################################################

""" code_edit """
func connect_gui_input(_control: Control, _on_gui_input: Callable) -> void:
	_control.gui_input.connect(_on_gui_input)

func connect_text_changed(_code_edit: CodeEdit, _on_text_changed: Callable) -> void:
	_code_edit.text_changed.connect(_on_text_changed)

func connect_value_changed(_code_edit: CodeEdit, _on_value_changed: Callable) -> void:
	var _vscroll := _code_edit.get_v_scroll_bar()
	_vscroll.value_changed.connect(_on_value_changed)

""" text_edit """
func connect_caret_changed(_text_edit: TextEdit, _on_caret_changed: Callable) -> void:
	_text_edit.caret_changed.connect(_on_caret_changed)

func connect_lines_edited_from(_text_edit: TextEdit, _on_lines_edited: Callable) -> void:
	_text_edit.lines_edited_from.connect(_on_lines_edited)

#endregion
################################################################################
#region control

""" focus_entered_exited """
func connect_focus_entered(_control: Control, _on_focus_entered: Callable) -> void:
	_control.focus_entered.connect(_on_focus_entered)

func connect_focus_exited(_control: Control, _on_focus_exited: Callable) -> void:
	_control.focus_exited.connect(_on_focus_exited)

""" mouse_entered_exited """
func connect_mouse_entered(_control: Control, _on_mouse_entered: Callable) -> void:
	_control.mouse_entered.connect(_on_mouse_entered)

func connect_mouse_exited(_control: Control, _on_mouse_exited: Callable) -> void:
	_control.mouse_exited.connect(_on_mouse_exited)

func connect_child_order_changed(_control: Control, _on_child_order_changed: Callable) -> void:
	_control.child_order_changed.connect(_on_child_order_changed)

func connect_child_entered_tree(_control: Control, _on_child_entered_tree: Callable) -> void:
	_control.child_entered_tree.connect(_on_child_entered_tree)

func connect_child_exiting_tree(_control: Control, _on_child_exiting_tree: Callable) -> void:
	_control.child_exiting_tree.connect(_on_child_exiting_tree)

#endregion
################################################################################
#region container

""" tab_container """
func connect_tab_changed(_tab_container: TabContainer, _on_tab_changed: Callable) -> void:
	_tab_container.tab_changed.connect(_on_tab_changed)

func connect_tab_selected(_tab_container: TabContainer, _on_tab_selected: Callable) -> void:
	_tab_container.tab_selected.connect(_on_tab_selected)

func connect_tab_clicked(_tab_container: TabContainer, _on_tab_clicked: Callable) -> void:
	_tab_container.tab_clicked.connect(_on_tab_clicked)

""" split_container """
func connect_drag_started(_split: SplitContainer, _on_drag_started: Callable) -> void:
	_split.drag_started.connect(_on_drag_started)

func connect_drag_ended(_split: SplitContainer, _on_drag_ended: Callable) -> void:
	_split.drag_ended.connect(_on_drag_ended)

#endregion
################################################################################
#region line_edit

""" line_edit """
func connect_line_edit_text_changed(_line_edit: LineEdit, _on_text_changed: Callable) -> void:
	_line_edit.text_changed.connect(_on_text_changed)

func connect_text_submitted(_line_edit: LineEdit, _on_text_submitted: Callable) -> void:
	_line_edit.text_submitted.connect(_on_text_submitted)

#endregion
################################################################################
#region popup_menu

""" popup_menu """
func connect_id_pressed(_menu_button: PopupMenu, _on_id_pressed: Callable) -> void:
	_menu_button.id_pressed.connect(_on_id_pressed)

func connect_index_pressed(_menu_button: PopupMenu, _on_index_pressed: Callable) -> void:
	_menu_button.index_pressed.connect(_on_index_pressed)

func connect_about_to_popup(_menu_button: MenuButton, _on_about_to_popup: Callable) -> void:
	_menu_button.about_to_popup.connect(_on_about_to_popup)

func connect_window_input(_window: Window, _on_window_input: Callable) -> void:
	_window.window_input.connect(_on_window_input)

func connect_visibility_changed(_window: Window, _on_visibility_changed: Callable) -> void:
	_window.visibility_changed.connect(_on_visibility_changed)

func connect_about_to_popup_window(_window: Window, _on_about_to_popup_window: Callable) -> void:
	_window.about_to_popup.connect(_on_about_to_popup_window)

func connect_close_request_window(_window: Window, _on_close_request_window: Callable) -> void:
	_window.close_requested.connect(_on_close_request_window)

#endregion
################################################################################

""" popup_hide """
func connect_popup_hide(_popup_panel: PopupPanel, _on_popup_hide: Callable) -> void:
	_popup_panel.popup_hide.connect(_on_popup_hide)


