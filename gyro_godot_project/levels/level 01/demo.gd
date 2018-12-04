extends Node

var platforms = preload("res://demo level/Platform.tscn")
signal rotate
var players = {}

func _ready():
	add_to_group("messengers")

func _on_connect(new_id):
	print("yay a new player")
	players[new_id] = platforms.instance()
	add_child(players[new_id])
	players[new_id].translation.x = randi() % 20 - 10
	players[new_id].translation.y = randi() % 10 - 5

func _process(delta):
	if players.size() != 0:
		$"../Position3D".translation = players.values()[-1].translation
		$"../Position3D".translation.z += 10

func _on_disconnect(msg):
	print("goodbye player")
	players[msg].queue_free()
	players.erase(msg)

#func _on_message(msg):
#	var data = JSON.parse(msg).result
#	players[data.id].rotated(data.x, data.y, data.z, data.w);

func _on_rotate(id, angle, tilt):
	players[id]._on_rotate(angle, tilt)

func _on_button(id, name, state):
	print("Button " + name + " turned " + state)