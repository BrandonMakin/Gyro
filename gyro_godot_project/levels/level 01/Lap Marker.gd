extends Spatial

var vehicle_progress_in_lap = {}
var vehicle_laps_completed = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for vehicle in $"../vehicles".get_children():
		vehicle_laps_completed[vehicle] = 0
		vehicle_progress_in_lap[vehicle] = 1

func _on_Lap_Tracker_00_body_entered(body):
	if body.is_in_group("vehicles"):
		if vehicle_progress_in_lap[body] == 02:
			vehicle_laps_completed[body] += 1
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