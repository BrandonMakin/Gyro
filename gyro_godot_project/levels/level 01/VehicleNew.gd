extends KinematicBody


const max_speed = 50  # [meters per second] 
const acceleration_strength = 7
export var sharpest_steering_radius = .1
export var speed = 0
var forward_acceleration = 0
var desired_rotation = Vector3(0,0,0)
var velocity = Vector2()
var steering_wheel_angle = 0
var drifting_direction = 0
var drifting_multiplier = 2 # higher multiplier means more responsive steering

export(int) var seconds_for_zero_to_max = 5 # time it takes to accelerate from zero to max_speed [seconds]
export(int) var seconds_for_max_to_zero = 5 # time it takes to brake from max_speed to zero [seconds]
var speed_level = 0 # represents some the current speed at value from 0 to 1, before interpolation. 0 means not moving and 1 means moving at max speed,
					# ...but depending on your interpolation, the values in between may not correlate linearly to the speeds they represent. [no units]

enum MovementInputFlags {
	NO_INPUT = 0,
	ACCELERATING = 1,
	BRAKING = 2,
	ACCELERATING_AND_BRAKING = 3  # This equals the bitwise union of accelerating and braking, i.e. ACCELERATING_AND_BRAKING == ACCELERATING | BRAKING
	}
var current_movement_input = MovementInputFlags.NO_INPUT

enum Vehicle {BIPLANE, UFO}
export(Vehicle) var vehicle_type = Vehicle.BIPLANE

func _ready():
	$Biplane.visible = false
	$UFO.visible = false
	if vehicle_type == Vehicle.UFO:
		$UFO.visible = true
	else:
		$Biplane.visible = true

func _on_rotate(angle, tilt):
	desired_rotation = Vector3((-tilt), angle * -2, angle * -2)
	steering_wheel_angle = angle# max(min(angle*1.7, .5), -.5) # ranges from -.5 to .5


func _on_button(name, state): #3 possible names for a button: accel, shoot, shock
	#2 states for a button: on, off
	
#	print("button: " + name + "! (" + state + ")")
	
	#ACCEL button
	if name == "accel": # set ACCELERATING bit of current_movement_input
		if state == "on":
			current_movement_input |= MovementInputFlags.ACCELERATING  # movement OR accelerating means keep current movement and add accelerating flag
		else:
			current_movement_input &= ~ MovementInputFlags.ACCELERATING # movement AND NOT accelerating means keep everything except for the accelerating flag
	
	#SHOCK button
	if name == "shock" and state == "on":
		get_tree().reload_current_scene()
	
	#SHOOT button
	if name == "shoot":
		if state == "on":
			current_movement_input != MovementInputFlags.BRAKING # add BRAKING flag
			start_drifting()
		else:
			current_movement_input &= ~ MovementInputFlags.BRAKING # remove BRAKING flag
			stop_drifting()
	
func _physics_process(delta):
	
	# Handle forward acceleration and braking. The current behavior is that braking overrides any acceleration input.  A player only accelerates if the player is not braking.
	if current_movement_input & MovementInputFlags.BRAKING == MovementInputFlags.BRAKING:  # check for BRAKING flag
		if speed_level >= 0:
			speed_level -= delta / seconds_for_max_to_zero # I think this is the correct way to make speed_level go from 1 to 0 in seconds_for_max_to_zero seconds, but I'm not sure.
		else:
			 speed_level = 0
		
		# Set the speed based on the speed_level.  If you want to control the BRACKING acceleration curve, do it here:
		speed = speed_level * max_speed
	
	elif current_movement_input & MovementInputFlags.ACCELERATING == MovementInputFlags.ACCELERATING: # else check for ACCELERATING flag
		if speed_level < 1:
			speed_level += delta / seconds_for_zero_to_max  # I think this is the correct way to make speed_level go from 0 to 1 in seconds_for_max_to_zero seconds, but I'm not sure.
		
		# Set the speed based on the speed_level.  If you want to control the ACCELERATING acceleration curve, do it here:
		speed = speed_level * max_speed
	
	
	#handle rotation around x and z axes (these are directly based on how you hold the phone)
	rotation.x = lerp(rotation.x, desired_rotation.x, delta*15)
	rotation.z = lerp(rotation.z, desired_rotation.z, delta*15)
	
	#handle rotation around the y axis (this is the complex one) 
	if drifting_direction != 0:
		steering_wheel_angle += -.02 * drifting_direction
	rotation.y -= steering_wheel_angle * delta / (2 * PI * sharpest_steering_radius)
	move_and_slide(-transform.basis.z * speed)

func reset():
	print("RESET")
	desired_rotation = Vector3()
	speed = 0
	forward_acceleration = 0

func start_drifting():
	drifting_direction = sign(desired_rotation.y)
	$Biplane.rotate_y(PI/5 * drifting_direction)
	$UFO.rotate_y(PI/5 * drifting_direction)

func stop_drifting():
	$Biplane.rotate_y(-PI/5 * drifting_direction)
	$UFO.rotate_y(-PI/5 * drifting_direction)
	drifting_direction = 0