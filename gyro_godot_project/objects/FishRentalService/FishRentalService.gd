extends Node

onready var vehicle_parent = $"../vehicles"
#var players_in_level = []
var max_players = 8
var player_count_in_this_level

var splitscreen2 = preload("res://objects/SplitscreenCamera/SplitscreenCamera.tscn")
var splitscreen4 = preload("res://objects/SplitscreenCamera/SplitscreenCamera-4Player.tscn")
var splitscreen8 = preload("res://objects/SplitscreenCamera/SplitscreenCamera-8Player.tscn")

func _ready():
	#warning-ignore:return_value_discarded
	Global.connect("player_connected", self, "_on_connect")
	#warning-ignore:return_value_discarded
	Global.connect("player_disconnected", self, "_on_disconnect")
	
	printerr("_ready: Global.players: " + str(Global.players))
	player_count_in_this_level = max(1, min(max_players, Global.players.size()))
	_fill_vehicles()
	add_splitscreen_camera()

func _on_connect(new_id):
	_add_vehicle(new_id)

#warning-ignore:unused_argument
func _on_disconnect(id):
#	_remove_player(id)
	pass

func _add_vehicle(new_id):
	print("adding a vehicle")
	# check if new_id exists as one of the vehicles
	for v in vehicle_parent.get_children():
		if v.player_id == new_id:
			print("oh nevermind")
			return
	# if not, then set the player_id of the first available vehicle to new_id 
	for v in vehicle_parent.get_children():
		if v.player_id == "":
			v.player_id = new_id
			return

func _fill_vehicles():
	for id in Global.players:
		_add_vehicle(id)

func add_splitscreen_camera():
	if player_count_in_this_level <= 2:
		get_parent().call_deferred("add_child", splitscreen2.instance())
	elif player_count_in_this_level <= 4:
		get_parent().call_deferred("add_child", splitscreen4.instance())
	else:
		get_parent().call_deferred("add_child", splitscreen8.instance())
	$"../Lap Marker".initialize()

#func _fill_vehicles():
#	for i in range(Global.players.size()): #for every player
#		#Precondition: this player is not already in the level
#		if players_in_level.has(Global.players[i]):
#			continue
#
#		# Find the first empty vehicle.
#		var vehicle_index = -1
#		for i in range(vehicles_available.size()):
#			if vehicles_available[i] == true:
#				vehicle_index = i
#				break
#		#If no vehicles are free, then stop here.
#		if vehicle_index == -1:
#			return
#
#		# Assign a vehicle to this player.
#		players_in_level[Global.players[i]] = vehicle_parent.get_child(vehicle_index)
#		# Tell that vehicle the ID of this player.
#		vehicle_parent.get_child(vehicle_index).player_id = Global.players[i]
#		# Mark that vehicle as unavailable.
#		vehicles_available[vehicle_index] = false

#func _remove_player(player_id):
#	if players_in_level.has(player_id):
#		# Mark the player's vehicle as available.
#		var vehicle = players_in_level[player_id]
#		vehicles_available[ vehicle.get_index() ] = true
#		# Reset the vehicle
#		players_in_level[player_id].swim_state.reset()
#		# And remove the player from the level.
#		players_in_level.erase(player_id)