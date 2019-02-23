extends KinematicBody


const max_speed = 50
const acceleration_strength = 7
export var sharpest_steering_radius_when_fast = 5
export var sharpest_steering_radius_when_slow = .1

export var speed = 0
var forward_acceleration = 0
var desired_rotation = Vector3(0,0,0)
var velocity = Vector2()
var steering_wheel_angle = 0
var drifting_direction = 0
var drifting_multiplier = 2 # higher multiplier means more responsive steering
export var current_sharpest_steering_radius = 0

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
	if name == "accel":
		if state == "on":
			forward_acceleration = acceleration_strength
		else:
			forward_acceleration = -acceleration_strength
	
	#SHOCK button
	if name == "shock" and state == "on":
		get_tree().reload_current_scene()
	
	#SHOOT button
	if name == "shoot":
		if state == "on":
			start_drifting()
		else:
			stop_drifting()
	
func _physics_process(delta):
	speed += (forward_acceleration - (0 if drifting_direction == 0 else (2 * acceleration_strength)) ) * delta
	if speed < 0:
		speed = 0
		forward_acceleration = 0
	elif speed > max_speed:
		speed = max_speed
	
	#handle rotation around x and z axes (these are directly based on how you hold the phone)
	rotation.x = lerp(rotation.x, desired_rotation.x, delta*15)
	rotation.z = lerp(rotation.z, desired_rotation.z, delta*15)
	
	#handle rotation around the y axis (this is the complex one) 
	current_sharpest_steering_radius = lerp(sharpest_steering_radius_when_slow, sharpest_steering_radius_when_fast, speed/max_speed)
	if drifting_direction != 0:
		steering_wheel_angle += -.02 * drifting_direction
	rotation.y -= steering_wheel_angle * speed * delta / (2 * PI * current_sharpest_steering_radius)
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