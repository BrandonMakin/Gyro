extends Node

var Vehicles = preload("res://levels/level 01/Vehicle.tscn")
signal rotate
var player_slots = []
var players = {}
var max_players = 2

func _ready():
	add_to_group("messengers")
	player_slots.append($"../player1")
	player_slots.append($"../player2")

func _on_connect(new_id):
	if players.size() < max_players:
		players[new_id] = player_slots[players.size()-1]

func _physics_process(delta):
	pass

func _on_disconnect(id):
	if players.has(id):
		players.erase(id)

func _on_rotate(id, angle, tilt):
	players[id]._on_rotate(angle, tilt)
	
func _on_button(id, name, state):
	players[id]._on_button(name, state)
	#print("Button " + name + " turned " + state)