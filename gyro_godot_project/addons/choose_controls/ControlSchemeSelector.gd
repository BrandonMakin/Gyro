tool
extends OptionButton

var ControlKeyboard = "res://scripts/controls/Control With Keyboard.gd"
var ControlLocal = "res://scripts/controls/Control With Local Server.gd"
var ControlRemote = "res://scripts/controls/Control With Remote Server.gd"

func _enter_tree():
	#warning-ignore:return_value_discarded
	connect("item_selected", self, "_item_selected")
	clear()
	add_item("Keep last control scheme used")
	add_item("Use mouse and keyboard")
	add_item("Use local server")
	add_item("Use remote server")

func _item_selected(id):
	use_control_scheme(id)

func use_control_scheme(id):
	var ep = EditorPlugin.new()
	ep.remove_autoload_singleton("ControlKeyboard")
	ep.remove_autoload_singleton("ControlLocal")
	ep.remove_autoload_singleton("ControlRemote")
	
	match id:
		1:
			ep.add_autoload_singleton("ControlKeyboard", ControlKeyboard)
		2:
			ep.add_autoload_singleton("ControlLocal", ControlLocal)
		3:
			ep.add_autoload_singleton("ControlRemote", ControlRemote)
	ep.free()