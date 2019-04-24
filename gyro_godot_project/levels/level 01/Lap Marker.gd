extends Spatial

var vehicles = {}
var players_finished = 0
onready var vehicle_count = $"../vehicles".get_child_count()

var vehicle_progress_in_lap = {}
var vehicle_laps_completed = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for vehicle in $"../vehicles".get_children():
		vehicle_laps_completed[vehicle] = 1
		vehicle_progress_in_lap[vehicle] = 00
		
	for i in range(vehicle_count):
		vehicles[i] = {}
		vehicles[i].finished = false
#		vehicles[i].current_lap = 1
#		vehicles[i].progress_in_lap = 0
		

func race_start():
	for i in range(vehicle_count):
		vehicles[i].start_time = OS.get_ticks_msec()

func race_end(i): # i == VehicleNumber
	vehicles[i].finished = true
	vehicles[i].time_taken = OS.get_ticks_msec() - vehicles[i].start_time
	players_finished += 1
	vehicles[i].rank = players_finished

func _on_Lap_Tracker_00_body_entered(body):
	if body.is_in_group("vehicles"):
		if vehicle_progress_in_lap[body] == 02:
			lap_completed(body)
			print("lap completed. on lap #" + str(vehicle_laps_completed[body]))
		
		vehicle_progress_in_lap[body] = 00

func _on_Lap_Tracker_01_body_entered(body):
	if body.is_in_group("vehicles"):
		if vehicle_progress_in_lap[body] == 00:
			vehicle_progress_in_lap[body] = 01

func _on_Lap_Tracker_02_body_entered(body):
	if body.is_in_group("vehicles"):
		if vehicle_progress_in_lap[body] == 01:
			vehicle_progress_in_lap[body] = 02

func lap_completed(body):
	var id = body.vehicle_number
	vehicle_laps_completed[body] += 1
	var laps = vehicle_laps_completed[body]
	if laps == 2:
		get_node("../GUI/LapMessages/lap2p%s" % id).visible = true
		yield(get_tree().create_timer(.5), "timeout") # wait for 0.5s
		get_node("../GUI/LapMessages/lap2p%s" % id).visible = false
	elif laps == 3:
		get_node("../GUI/LapMessages/lap3p%s" % id).visible = true
		yield(get_tree().create_timer(.5), "timeout") # wait for 0.5s
		get_node("../GUI/LapMessages/lap3p%s" % id).visible = false
	elif laps == 4:
		get_node("../GUI/LapMessages/race_finished_p%s" % id).visible = true