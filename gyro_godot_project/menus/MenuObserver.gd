extends Control

var players = {}
var cursor = preload("res://menus/Cursor.tscn")
export(PackedScene) var level_1

func _ready():
	Global.connect("player_connected", self, "_on_connect")
	Global.connect("player_disconnected", self, "_on_disconnect")
	Global.connect("player_rotated", self, "_on_rotate")
	Global.connect("player_button_pressed", self, "_on_button")

func _on_connect(id):
	players[id] = cursor.instance()
	players[id].position = Vector2(700, 500)
	add_child(players[id])

func _on_rotate(id, angle, tilt):
#	print("angle: " + str(angle) + ", tilt: " + str(tilt))
	if players.has(id):
		players[id]._move(angle, tilt)

func _on_button(id, button_name, state):
	if button_name == "accel":
		if $"../Start Button".get_rect().has_point( players[id].position ) :
			get_tree().change_scene_to(level_1)

func _on_disconnect(id):
	players[id].queue_free()
	players.erase(id)