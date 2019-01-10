extends KinematicBody


var max_speed = 100
var acceleration_strength = 15
var speed = 0
var forward_acceleration = 0
var desired_rotation = Vector3(0,0,0)
var velocity = Vector2()

var steering_wheel_angle = 0
export var sharpest_steering_radius_when_fast = 5
export var sharpest_steering_radius_when_slow = .1
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
	print("button: " + name + "! (" + state + ")")
	if name == "accel":
		if state == "on":
			forward_acceleration = acceleration_strength
		else:
			forward_acceleration = -2 * acceleration_strength
	if name == "shock" and state == "on":
		get_tree().reload_current_scene()
	
func _physics_process(delta):
	speed += forward_acceleration * delta
	if speed < 0:
		speed = 0
		forward_acceleration = 0
	
	if speed > max_speed:
		speed = max_speed	
	
	current_sharpest_steering_radius = lerp(sharpest_steering_radius_when_slow, sharpest_steering_radius_when_fast, speed/max_speed)
	rotation.z = desired_rotation.z
	rotation.y -= steering_wheel_angle * speed * delta / (2 * PI * current_sharpest_steering_radius)
	rotation.x = desired_rotation.x
	move_and_slide(-transform.basis.z * speed)
	

func reset():
	print("RESET")
	desired_rotation = Vector3()
#	rotation = Vector3()
	speed = 0
	forward_acceleration = 0