extends HTTPRequest

var platforms = preload("res://level 001/Platform.tscn")
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
	

func _on_disconnect(msg):
	print("goodbye player")
	players[msg].queue_free()
	players.erase(msg)

func _on_message(msg):
	var data = JSON.parse(msg).result
	players[data.id].rotated(data.x, data.y, data.z, data.w);
	
func _on_button(id, name, state):
	print("Button " + name + " turned " + state)