extends Node

var Vehicles = preload("res://levels/level 01/Vehicle.tscn")
signal rotate
onready var vehicle_parent = $"../vehicles"
var vehicles_available = []
var vehicles_occupied = []
var players = {}
var max_players = 2

func _ready():
	add_to_group("messengers")
	for child in vehicle_parent.get_children():
		vehicles_available.append(child)
	printerr(vehicles_available)
	
func _on_connect(new_id):
	# When a new player connects: if there are any available vehicles,
	# then match a player to a vehicle and make the vehicle occupied. 
	if (vehicles_available.size()):
		players[new_id] = vehicles_available[-1]
		vehicles_occupied.append(vehicles_available[-1])
		vehicles_available.remove(0)
	printerr(vehicles_available)

func _physics_process(delta):
	pass

func _on_disconnect(id):
	printerr("deleting " + id)
	if players.has(id):
		vehicles_available.append(players[id])
		vehicles_occupied.remove( vehicles_occupied.find(players[id]) )
		players.erase(id)
	printerr(vehicles_available)

func _on_rotate(id, angle, tilt):
	players[id]._on_rotate(angle, tilt)
	
func _on_button(id, name, state):
	players[id]._on_button(name, state)
	#print("Button " + name + " turned " + state)