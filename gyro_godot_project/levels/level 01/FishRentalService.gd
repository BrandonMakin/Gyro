extends Node

var Vehicles = preload("res://objects/Vehicle/Vehicle.tscn")
onready var vehicle_parent = $"../vehicles"
var vehicles_available = []  # array of boolean values. true means available.
onready var max_players_allowed = vehicles_available.size()
var players_in_level = {}

func _ready():
	Global.connect("player_connected", self, "_on_connect")
	Global.connect("player_disconnected", self, "_on_disconnect")
	
	for i in range(vehicle_parent.get_child_count()):
		vehicles_available.append(true)
	printerr("_ready: Global.players: " + str(Global.players))
	_fill_vehicles()
	printerr("_ready: vehicles available: " + str(vehicles_available))
	
func _on_connect(new_id):
	_fill_vehicles()

func _on_disconnect(id):
	_remove_player(id)

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
		players_in_level[Global.players[i]] = vehicle_parent.get_child(vehicle_index)
		# Tell that vehicle the ID of this player.
		vehicle_parent.get_child(vehicle_index).player_id = Global.players[i]
		# Mark that vehicle as unavailable.
		vehicles_available[vehicle_index] = false

func _remove_player(player_id):
	if players_in_level.has(player_id):
		# Mark the player's vehicle as available.
		var vehicle = players_in_level[player_id]
		vehicles_available[ vehicle.get_index() ] = true
		# Reset the vehicle
		players_in_level[player_id].swim_state.reset()
		# And remove the player from the level.
		players_in_level.erase(player_id)