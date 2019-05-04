extends Control

var players = {}
var cursor = preload("res://menus/Cursor.tscn")
export(PackedScene) var level_1
export(PackedScene) var level_2

func _ready():
	#warning-ignore:return_value_discarded
	Global.connect("player_connected", self, "_on_connect")
	#warning-ignore:return_value_discarded
	Global.connect("player_disconnected", self, "_on_disconnect")
	#warning-ignore:return_value_discarded
	Global.connect("player_rotated", self, "_on_rotate")
	#warning-ignore:return_value_discarded
	Global.connect("player_button_pressed", self, "_on_button")
	#warning-ignore:return_value_discarded
	Global.connect("color_scheme", self, "_on_color_scheme")

func _on_connect(id):
	players[id] = cursor.instance()
	players[id].position = Vector2(700, 500)
	add_child(players[id])

func _on_rotate(id, angle, tilt):
#	print("angle: " + str(angle) + ", tilt: " + str(tilt))
	if players.has(id):
		players[id]._move(angle, tilt)

func _on_color_scheme(player_id, scheme_id):
	players[player_id]._on_color_scheme(scheme_id)

#warning-ignore:unused_argument
func _on_button(id, button_name, state):
	if button_name == "accel":
		if $"../Level1 Start Button".get_rect().has_point( players[id].position ) :
			#warning-ignore:return_value_discarded
			get_tree().change_scene_to(level_1)
		elif $"../Level2 Start Button".get_rect().has_point( players[id].position ) :
			#warning-ignore:return_value_discarded
			get_tree().change_scene_to(level_2)
func _on_disconnect(id):
	players[id].queue_free()
	players.erase(id)