extends Node

var player_id : String = ""
const max_speed = 50  # [meters per second] 
const acceleration_strength = 7
export var sharpest_steering_radius = .1
export var speed = 0
var forward_acceleration = 0
var desired_rotation = Vector3(0,0,0)
var steering_wheel_angle = 0
var drifting_direction_x = 0
var drifting_direction_y = 0
var drifting_multiplier = 2 # higher multiplier means more responsive steering [no units, multiplier]
var min_drifting_speed_level = .2 # minimum fish_king.speed_level wherein drifting is still possible [no units, range: 0-1]
var is_side_drifting = false
var is_vertical_drifting = false
onready var fish_king = $"../.."

export(int) var seconds_for_zero_to_max = 5 # time it takes to accelerate from zero to max_speed [seconds]
export(int) var seconds_for_max_to_zero = 5 # time it takes to brake from max_speed to zero [seconds]

					# ...but depending on your interpolation, the values in between may not correlate linearly to the speeds they represent. [no units, range: 0-1]

enum MovementInputFlags {
	NO_INPUT = 0,
	ACCELERATING = 1,
	BRAKING = 2,
	ACCELERATING_AND_BRAKING = 3  # This equals the bitwise union of accelerating and braking, i.e. ACCELERATING_AND_BRAKING == ACCELERATING | BRAKING
	}
	
var current_movement_input = MovementInputFlags.NO_INPUT

func _ready():
	pass

func _on_rotate(id, angle, tilt):
	desired_rotation = Vector3((-tilt), angle * -2, angle * -2)
	steering_wheel_angle = angle # max(min(angle*1.7, .5), -.5) # ranges from -.5 to .5


func _on_button(id, name, state): #3 possible names for a button: accel, shoot, shock
	#2 states for a button: on, off
	
#	print("button: " + name + "! (" + state + ")")
	
	#ACCEL button
	if name == "accel": # set ACCELERATING bit of current_movement_input
		if state == "on":
			current_movement_input |= MovementInputFlags.ACCELERATING  # movement OR accelerating means keep current movement and add accelerating flag
			current_movement_input &= ~ MovementInputFlags.BRAKING
		else:
			current_movement_input |= MovementInputFlags.BRAKING
			current_movement_input &= ~ MovementInputFlags.ACCELERATING # movement AND NOT accelerating means keep everything except for the accelerating flag
	
	#SHOCK button
	if name == "shock" and state == "on":
		get_tree().reload_current_scene()
	
	#SHOOT button
	if name == "shoot":
		if state == "on":
			#current_movement_input |= MovementInputFlags.BRAKING # add BRAKING flag
			start_drifting()
		else:
			#current_movement_input &= ~ MovementInputFlags.BRAKING # remove BRAKING flag
			stop_drifting()
	
func _state_physics_process(delta):
	
	
	# Handle forward acceleration and braking. The current behavior is that braking overrides any acceleration input.  A player only accelerates if the player is not braking.
	if current_movement_input & MovementInputFlags.BRAKING == MovementInputFlags.BRAKING:  # check for BRAKING flag
#		print("braking")
		if fish_king.speed_level >= 0:
			fish_king.speed_level -= delta / seconds_for_max_to_zero # I think this is the correct way to make fish_king.speed_level go from 1 to 0 in seconds_for_max_to_zero seconds, but I'm not sure.
		else:
			 fish_king.speed_level = 0
		
		# Set the speed based on the fish_king.speed_level.  If you want to control the BRACKING acceleration curve, do it here:
		speed = fish_king.speed_level * max_speed
	
	elif current_movement_input & MovementInputFlags.ACCELERATING == MovementInputFlags.ACCELERATING: # else check for ACCELERATING flag
#		print("accelerating")
		if fish_king.speed_level < 1:
			fish_king.speed_level += delta / seconds_for_zero_to_max  # I think this is the correct way to make fish_king.speed_level go from 0 to 1 in seconds_for_max_to_zero seconds, but I'm not sure.
		
		# Set the speed based on the fish_king.speed_level.  If you want to control the ACCELERATING acceleration curve, do it here:
		speed = fish_king.speed_level * max_speed
	
	#DEPRECATED VERTICAL DRIFTING CODE
	#	if drifting_direction_x != 0 && fish_king.speed_level > min_drifting_speed_level:
#		desired_rotation.x *= 2
#		if desired_rotation.x > 0.99:
#			desired_rotation.x = 0.99
#		elif desired_rotation.x < -0.99:
#			desired_rotation.x = -0.99
#		fish_king.rotation.x = lerp(fish_king.rotation.x, desired_rotation.x, delta*15)
#	else:

	#handle fish_king.rotation around x and z axes (these are directly based on how you hold the phone)

	fish_king.rotation.x = lerp(fish_king.rotation.x, desired_rotation.x, delta*15)
	fish_king.rotation.z = lerp(fish_king.rotation.z, desired_rotation.z, delta*15)
	
	#handle fish_king.rotation around the y axis (this is the complex one) 
	if drifting_direction_y != 0 && fish_king.speed_level > min_drifting_speed_level:
		fish_king.rotation.y += .01 * drifting_direction_y
	fish_king.rotation.y -= steering_wheel_angle * delta / (2 * PI * sharpest_steering_radius)
	fish_king.move_and_slide(-fish_king.transform.basis.z * speed)

func reset():
	print("RESET")
	desired_rotation = Vector3()
	speed = 0
	forward_acceleration = 0

func start_drifting():
	if sign(desired_rotation.y) != 0:
		is_side_drifting = true
		drifting_direction_y = sign(desired_rotation.y)
		$"../../Fish".rotate_y(PI/5 * drifting_direction_y)
	
#	DEPRECATED VERTICAL DRIFTING CODE	
#	print (desired_rotation.x)
#	if desired_rotation.x > 0.3 || desired_rotation.x < -0.3:
#		is_vertical_drifting = true
#		drifting_direction_x = sign(desired_rotation.x)
#		$"../../Fish".rotate_x(PI/5 * drifting_direction_x)

func stop_drifting():
	
	#DEPRECATED VERTICAL DRIFTING CODE
#	if (is_vertical_drifting):
#		$"../../Fish".rotate_x(-PI/5 * drifting_direction_x)
#		drifting_direction_x = 0
#		is_vertical_drifting = false
	
	if (is_side_drifting):
		$"../../Fish".rotate_y(-PI/5 * drifting_direction_y)
		drifting_direction_y = 0
		is_side_drifting = false