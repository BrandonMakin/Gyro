extends Spatial

var vehicles = {}
var placements = []
var players_finished = 0
onready var vehicle_count = $"../vehicles".get_child_count()
onready var splitscreen = $"../SplitscreenCamera"


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(vehicle_count):
		placements.append(i)
		vehicles[i] = {}
		vehicles[i].finished = false
		vehicles[i].current_lap = 1
		vehicles[i].progress_in_lap = 0
		vehicles[i].rank = 0
	
	# connect all the children's body_entered to _on_Lap_Tracker_body_entered
	for i in range(get_child_count()):
		if i == 0:
			continue # skip the Lap Tracker #0 because it's a special case.
		# connect the signal to the function and bind i as an extra argument. 
#warning-ignore:return_value_discarded
		get_child(i).connect("body_entered", self, "_on_Lap_Tracker_body_entered", [i])

func _process(delta):
	placements.sort_custom(self, "sort")
	for i in range(placements.size()):
		splitscreen.get_cam_gui(placements[i]).get_node("Rank/Inside/Label").text = str(i+1) + get_ordinal(i+1) + " place"

func race_start():
	for i in range(vehicle_count):
		vehicles[i].start_time = OS.get_ticks_msec()

func race_finish(id): # id == VehicleNumber
	vehicles[id].finished = true
	vehicles[id].time_taken = OS.get_ticks_msec() - vehicles[id].start_time
	players_finished += 1
	vehicles[id].rank = players_finished
	
	splitscreen.get_cam_gui(id).get_node("LapAlerts/RaceFinished").visible = true
	set_process(false)
	var ordinal = get_ordinal(players_finished)
	splitscreen.get_cam_gui(id).get_node("Rank/Inside/Label").text = str(players_finished) + ordinal + " Place"
	splitscreen.get_cam_gui(id).get_node("Lap/Inside/Animation").play("Finished")
	splitscreen.get_cam_gui(id).get_node("Rank/Inside/Animation").play("Finished")
	

func _on_Lap_Tracker_00_body_entered(body):
	if body.is_in_group("vehicles"):
		var id = body.vehicle_number
		if vehicles[id].progress_in_lap == get_child_count() - 1:
			lap_completed(body)
#			print("lap completed on lap #" + str(vehicles[id].current_lap))
		
		vehicles[id].progress_in_lap = 0

func _on_Lap_Tracker_body_entered(body, tracker_number):
	if body.is_in_group("vehicles"):
		var id = body.vehicle_number
		print("previous tracker number: " + str(vehicles[id].progress_in_lap))
		print("previous == expected: " + str(vehicles[id].progress_in_lap == tracker_number-1))
		if vehicles[id].progress_in_lap == tracker_number-1:
			vehicles[id].progress_in_lap = tracker_number

func lap_completed(body):
	var id = body.vehicle_number
	vehicles[id].current_lap += 1
	var laps = vehicles[id].current_lap
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

func get_ordinal(rank):
	match rank:
		1: return "st"
		2: return "nd"
		3: return "rd"
		_: return "th"

func sort(id1, id2):
	if vehicles[id1].current_lap != vehicles[id2].current_lap:
		return vehicles[id1].current_lap > vehicles[id2].current_lap
	elif vehicles[id1].progress_in_lap != vehicles[id2].progress_in_lap:
		return vehicles[id1].progress_in_lap > vehicles[id2].progress_in_lap
	else:
		# find who is closest to next lap marker
		var next_lap_marker = get_child(vehicles[id1].progress_in_lap + 1)
		var marker_pos = next_lap_marker.translation
		var dist1 = $"../vehicles".get_child(id1).translation.distance_to(marker_pos)
		var dist2 = $"../vehicles".get_child(id1).translation.distance_to(marker_pos)
		return dist1 > dist2