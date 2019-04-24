extends Spatial

var vehicles = {}
var players_finished = 0
onready var vehicle_count = $"../vehicles".get_child_count()
onready var splitscreen = $"../SplitscreenCamera"

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

func race_finish(id): # id == VehicleNumber
	vehicles[id].finished = true
	vehicles[id].time_taken = OS.get_ticks_msec() - vehicles[id].start_time
	players_finished += 1
	vehicles[id].rank = players_finished
	
	splitscreen.get_cam_gui(id).get_node("LapAlerts/RaceFinished").visible = true
	var ordinal = "th"
	match players_finished:
		1: ordinal = "st"
		2: ordinal = "nd"
		3: ordinal = "rd"
	splitscreen.get_cam_gui(id).get_node("Lap/Inside/Label").text = str(players_finished) + ordinal + " Place"
	splitscreen.get_cam_gui(id).get_node("Lap/Inside/Animation").play("Finished")
	

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
		splitscreen.get_cam_gui(id).get_node("Lap/Inside/Label").text = "Lap 2/3"
		splitscreen.get_cam_gui(id).get_node("LapAlerts/Lap2").visible = true
		yield(get_tree().create_timer(.5), "timeout") # wait for 0.5s
		splitscreen.get_cam_gui(id).get_node("LapAlerts/Lap2").visible = false
	elif laps == 3:
		splitscreen.get_cam_gui(id).get_node("Lap/Inside/Label").text = "Lap 3/3"
		splitscreen.get_cam_gui(id).get_node("LapAlerts/Lap3").visible = true
		yield(get_tree().create_timer(.5), "timeout") # wait for 0.5s
		splitscreen.get_cam_gui(id).get_node("LapAlerts/Lap3").visible = false
	elif laps == 4:
		race_finish(id)