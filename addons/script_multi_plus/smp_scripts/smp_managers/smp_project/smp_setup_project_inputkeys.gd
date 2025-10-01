@tool
class_name ScriptMultiPlusProjectInputKeys
extends Resource


const RES_PATH: String = "res://addons/script_multi_plus/sme_data_inputkeys/%s.tres"

var _shortcut_label: String = "ShortcutKeys"


var _shortcut_key_maps: Array[Dictionary] = [
	{
		"name"         : RES_PATH % "open_recent",
		"label"        : "OpenRecent",
		"pressed"      : true,
		"keycode"      : KEY_BRACKETRIGHT,
		"alt_pressed"  : false,
		"shift_pressed": true,
		"ctrl_pressed" : true,
		"meta_pressed" : true,
		"echo"         : false,
	},
	{
		"name"         : RES_PATH % "focus_1",
		"label"        : "Focus_1",
		"pressed"      : true,
		"keycode"      : KEY_1,
		"alt_pressed"  : false,
		"shift_pressed": true,
		"ctrl_pressed" : true,
		"meta_pressed" : true,
		"echo"         : false,
	},
	{
		"name"         : RES_PATH % "focus_2",
		"label"        : "Focus_2",
		"pressed"      : true,
		"keycode"      : KEY_2,
		"alt_pressed"  : false,
		"shift_pressed": true,
		"ctrl_pressed" : true,
		"meta_pressed" : true,
		"echo"         : false,
	},
	{
		"name"         : RES_PATH % "focus_3",
		"label"        : "Focus_3",
		"pressed"      : true,
		"keycode"      : KEY_3,
		"alt_pressed"  : false,
		"shift_pressed": true,
		"ctrl_pressed" : true,
		"meta_pressed" : true,
		"echo"         : false,
	},
	{
		"name"         : RES_PATH % "text_scroll_up",
		"label"        : "TextScrollUp",
		"pressed"      : true,
		"keycode"      : KEY_UP,
		"alt_pressed"  : false,
		"shift_pressed": false,
		"ctrl_pressed" : true,
		"meta_pressed" : true,
		"echo"         : false,
	},
	{
		"name"         : RES_PATH % "text_scroll_down",
		"label"        : "TextScrollDown",
		"pressed"      : true,
		"keycode"      : KEY_DOWN,
		"alt_pressed"  : false,
		"shift_pressed": false,
		"ctrl_pressed" : true,
		"meta_pressed" : true,
		"echo"         : false,
	},
	{
		"name"         : RES_PATH % "jump_previous",
		"label"        : "JumpPrevious",
		"pressed"      : true,
		"keycode"      : KEY_SLASH,
		"alt_pressed"  : false,
		"shift_pressed": true,
		"ctrl_pressed" : true,
		"meta_pressed" : true,
		"echo"         : false,
	},
	{
		"name"         : RES_PATH % "jump_next",
		"label"        : "JumpNext",
		"pressed"      : true,
		"keycode"      : KEY_BACKSLASH,
		"alt_pressed"  : false,
		"shift_pressed": true,
		"ctrl_pressed" : true,
		"meta_pressed" : true,
		"echo"         : false,
	},
]









