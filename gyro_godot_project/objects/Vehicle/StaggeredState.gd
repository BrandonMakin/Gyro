extends Node

onready var fish_king = $"../.."
var timer : int = 50 #Time to staggered state being popped

func _state_physics_process(delta):
	timer -= delta
	if timer <= 0:
		timer = 50 #Resetting timer before popping the state
		print("StaggerState Popped")
		fish_king.pop_state()
	
	#Fish decelerates twice as fast as normal when staggered and cannot be sped up
	if fish_king.speed_level >= 0:
		fish_king.speed_level -= 2 * delta / fish_king.swim_state.seconds_for_max_to_zero # Stolen Deceleration code from swim_state
	else:
		fish_king.speed_level = 0

#warning-ignore:unused_argument
#warning-ignore:unused_argument
func _on_rotate(angle, tilt):
	pass

#warning-ignore:unused_argument
#warning-ignore:unused_argument
func _on_button(angle, tilt):
	pass