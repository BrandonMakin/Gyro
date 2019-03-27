extends Spatial

var vehicle_progress_in_lap = {}
var vehicle_laps_completed = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for vehicle in $"../vehicles".get_children():
		vehicle_laps_completed[vehicle] = 1
		vehicle_progress_in_lap[vehicle] = 00

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
	vehicle_laps_completed[body] += 1
	var laps = vehicle_laps_completed[body]
	if body.get_name() == "vehicle1":
		if laps == 2:
			$"../GUI/LapMessages/lap2p1".visible = true
			yield(get_tree().create_timer(.5), "timeout") # wait for 0.5s
			$"../GUI/LapMessages/lap2p1".visible = false
		elif laps == 3:
			$"../GUI/LapMessages/lap3p1".visible = true
			yield(get_tree().create_timer(.5), "timeout") # wait for 0.5s
			$"../GUI/LapMessages/lap3p1".visible = false
		elif laps == 4:
			$"../GUI/LapMessages/race_finished_p1".visible = true
		
	elif body.get_name() == "vehicle2":
		if laps == 2:
			$"../GUI/LapMessages/lap2p2".visible = true
			yield(get_tree().create_timer(.5), "timeout") # wait for 0.5s
			$"../GUI/LapMessages/lap2p2".visible = false
		elif laps == 3:
			$"../GUI/LapMessages/lap3p2".visible = true
			yield(get_tree().create_timer(.5), "timeout") # wait for 0.5s
			$"../GUI/LapMessages/lap3p2".visible = false
		elif laps == 4:
			$"../GUI/LapMessages/race_finished_p1".visible = true
	
	else:
		printerr("Lap Marker.gd: Unkown vehicle with name: " + body.get_name())