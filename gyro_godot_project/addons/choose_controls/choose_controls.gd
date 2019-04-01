tool
extends EditorPlugin

var dock

# Initialization of the plugin.
func _enter_tree():
	# load and instance the deck scene
	dock = preload("ControlSchemeSelector.tscn").instance()
	# Add the scene to the docks
	add_control_to_bottom_panel(dock, "Choose Controls")

# Clean-up of the plugin.
func _exit_tree():
	# remove the dock
	remove_control_from_bottom_panel(dock)
	dock.free()

func has_main_screen():
   return true