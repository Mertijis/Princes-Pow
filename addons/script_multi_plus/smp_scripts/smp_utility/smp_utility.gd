@tool
class_name ScriptMultiPlusUtility
extends Resource


##:: getter
################################################################################
#region getter

func _get_script_editor() -> ScriptEditor:
	return EditorInterface.get_script_editor()

func _get_code_edit() -> CodeEdit:
	var _script_editor := _get_script_editor()
	var _sc_current := _script_editor.get_current_editor()
	if _sc_current != null:
		var _code_edit := _sc_current.get_base_editor() as CodeEdit
		return _code_edit
	return null

func _get_code_edit_from_base(_sc_editor_base: ScriptEditorBase) -> CodeEdit:
	var _sc_current := _sc_editor_base
	if _sc_current != null:
		var _code_edit := _sc_current.get_base_editor() as CodeEdit
		return _code_edit
	return null

func _get_script_item_list() -> ItemList:
	var _script_editor := _get_script_editor()
	var _script_list_container := _find_container(_script_editor)
	return _find_item_list(_script_list_container)

func _get_distraction_button() -> Button:
	var _base_control := EditorInterface.get_base_control()
	var _editor_scene_tabs: Node = _find_node(_base_control, "EditorSceneTabs")
	var _editor_distract_button: Button = _find_get_button(_editor_scene_tabs, "Button")
	#print("distruct_button: ", _editor_distract_button)
	return _editor_distract_button

#endregion
################################################################################

##:: find
################################################################################
#region find_node

func _find_editor_container(
	_node: Node, _find_class: String, dep: int = 0, d_max: int = 8
	) -> Node:
	if dep > d_max:
		return null
	if _node and _node.is_class(_find_class):
		return _node
	for child in _node.get_children():
		if child is Node:
			var _found := _find_editor_container(child, _find_class, dep + 1, d_max)
			if _found != null:
				return _found
	return null

func _find_editor_container_avoid(
	_node: Node, _find_class: String, dep: int = 0, d_max: int = 8
	) -> Node:
	if dep > d_max:
		return null
	if _node and _node.is_class(_find_class):
		return _node
	for child in _node.get_children():
		if child.name == "RegionFolder":
			continue
		if child is Node:
			var _found := _find_editor_container_avoid(child, _find_class, dep + 1, d_max)
			if _found != null:
				return _found
	return null

func _find_container(_node: Node) -> Node:
	if _node is HSplitContainer:
		return _node
	for child in _node.get_children():
		var _found := _find_container(child)
		if _found is VBoxContainer:
			return _found
		if _found is HSplitContainer:
			return _found
	return null

func _find_item_list(_node: Node) -> Node:
	if _node is ItemList:
		return _node
	for child in _node.get_children():
		var _found := _find_item_list(child)
		if _found is VBoxContainer:
			return _found
		if _found is ItemList:
			return _found
	return null

func _find_code_edit_parent(
	_node: Node, _find_class: String, dep: int = 0, d_max: int = 5
	) -> Node:
	if dep > d_max:
		return null
	if _node and _node.is_class(_find_class):
		return _node

	var _parent := _node.get_parent()

	if _parent is SMPDockContainer:
		return _parent

	if _parent and _parent.is_class(_find_class):
		return _parent

	return _find_code_edit_parent(_parent, _find_class, dep + 1, d_max)

func _find_parent_dock_container(
	_node: Node, dep: int = 0, d_max: int = 5
	) -> Node:
	if dep > d_max:
		return null
	if _node is SMPDockContainer:
		return _node

	var _parent := _node.get_parent()

	return _find_parent_dock_container(_parent, dep + 1, d_max)

#endregion
################################################################################
##:: distract_button
#region _find_distruct_button

func _find_node(_node: Node, _find_name: String) -> Node:
	if _node.is_class(_find_name):
		return _node
	for child in _node.get_children():
		var _found := _find_node(child, _find_name)
		if _found is Node:
			return _found
	return null

func _find_get_button(_node: Node, _find_class: String) -> Node:
	if _node.is_class(_find_class):
		return _node
	for child in _node.get_children():
		if child is PanelContainer:
			return _find_get_button(child, "HBoxContainer")
		elif child is HBoxContainer:
			for f_child in child.get_children():
				if f_child is Button:
					return f_child
	return null

#endregion
################################################################################
##:: line_edit
#region _find_line_edit

func _find_replace_line_edit(_node: Node, _find_class: String, dep: int = 0, d_max: int = 8) -> Node:
	var _find_replace_bar: Node
	for child in _node.get_children():
		if child and child.is_class("FindReplaceBar"):
			_find_replace_bar = child
			if _find_class == "FindReplaceBar":
				return _find_replace_bar

	if _find_replace_bar != null:
		if dep > d_max:
			return null
		for child in _find_replace_bar.get_children():
			if child is Node:
				var _found := _find_editor_container(child, _find_class, dep + 1, d_max)
				if _found != null:
					return _found
	return null

#endregion
################################################################################
#region _find_line_edit_buttons

func _find_get_button_up(_node: Node) -> Array[Button]:
	var _line_edit_parent: VBoxContainer = _node.get_parent()
	var _find_replace_bar: Node = _line_edit_parent.get_parent()
	var _button_container_index: int = _line_edit_parent.get_index() + 1
	var _button_container: VBoxContainer = _find_replace_bar.get_child(_button_container_index)
	var _button_up: Button
	var _button_down: Button

	if _button_container != null:
		for child in _button_container.get_children():
			if child is HBoxContainer:
				for cchild in child.get_children():
					if cchild is Button:
						if _button_up == null:
							_button_up = cchild
							continue
						if _button_down == null:
							_button_down = cchild
							break

	return [_button_up, _button_down]

#endregion
################################################################################
#region _find_file_dock_tree

func _find_node_tree(_node: Node) -> Node:
	if _node is Tree:
		return _node
	for child in _node.get_children():
		if child is SplitContainer:
			return _find_node_tree(child)
		if child is Tree:
			return child
	return null

#endregion
################################################################################
#region _find_simple_children

func _find_get_children(_node: Node, _find_class: String) -> Node:
	for child in _node.get_children():
		if child.is_class(_find_class):
			return child
	return null

#endregion
################################################################################

