extends Node

var Vehicles = preload("res://levels/level 01/Vehicle.tscn")
signal rotate
export(NodePath) var vehicle_parent
var vehicles_available = []  # array of boolean values. true means available.
onready var max_players_allowed = vehicles_available.size()
var players_in_level = {}

func _ready():
	add_to_group("messengers")
	for i in range(get_node(vehicle_parent).get_child_count()):
		vehicles_available.append(true)
	printerr("_ready: Global.players: " + str(Global.players))
	_fill_vehicles()
	printerr("_ready: vehicles available: " + str(vehicles_available))
	
func _on_connect(new_id):
	_fill_vehicles()

func _on_disconnect(id):
	_remove_player(id)

func _on_rotate(id, angle, tilt):
	if players_in_level.has(id):
		players_in_level[id]._on_rotate(angle, tilt)

func _on_button(id, name, state):
	if players_in_level.has(id):
		players_in_level[id]._on_button(name, state)
	#print("Button " + name + " turned " + state)

func _fill_vehicles():
	for i in range(Global.players.size()): #for every player
		#Precondition: this player is not already in the level
		if players_in_level.has(Global.players[i]):
			continue
		
		# Find the first empty vehicle.
		var vehicle_index = -1
		for i in range(vehicles_available.size()):
			if vehicles_available[i] == true:
				vehicle_index = i
				break
		#If no vehicles are free, then stop here.
		if vehicle_index == -1:
			return
		
		# Assign a vehicle to this player.
		players_in_level[Global.players[i]] = get_node(vehicle_parent).get_child(vehicle_index)
		# Mark that vehicle as unavailable.
		vehicles_available[vehicle_index] = false

func _remove_player(player_id):
	if players_in_level.has(player_id):
		# Mark the player's vehicle as available.
		var vehicle = players_in_level[player_id]
		vehicles_available[ vehicle.get_index() ] = true
		# Reset the vehicle
		players_in_level[player_id].reset()
		# And remove the player from the level.
		players_in_level.erase(player_id)