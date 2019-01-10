extends KinematicBody2D

var color
var max_speed = 400
var acceleration_strength = 40
var speed = 0
var forward_acceleration = 0
var velocity = Vector2()

var steering_wheel_angle = 0 # angle ranges from -1 to 1
export var sharpest_steering_radius_when_fast = 14
export var sharpest_steering_radius_when_slow = 1
export var current_sharpest_steering_radius = 0


func _ready():
	pass

func _process(delta):
	update()
	$SteeringWheel.rotation = steering_wheel_angle * PI - rotation
	
	speed += forward_acceleration * delta
	
	if speed < 0:
		speed = 0
		forward_acceleration = 0
	
	if speed > max_speed:
		speed = max_speed
		if forward_acceleration > 0:
			forward_acceleration = 0
#	var radius
	if steering_wheel_angle == 0:
		move_and_slide(Vector2(0,1).rotated(rotation) * speed)
	else:
		current_sharpest_steering_radius = lerp(sharpest_steering_radius_when_slow, sharpest_steering_radius_when_fast, speed/max_speed)
		var wheel_direction = sign(steering_wheel_angle)
		var radius = current_sharpest_steering_radius * abs(1 / sin(steering_wheel_angle * PI / 2))
		var y = radius * sin(1 / radius)
		var x = radius * ( 1 - cos(1 / radius) ) * -wheel_direction
		move_and_slide(Vector2(x, y).rotated(rotation) * speed)
		rotate(wheel_direction * speed * delta / (2 * PI * radius))

func reset():
	speed = 0

func _on_rotate(angle, tilt):
	steering_wheel_angle = max(min(angle*1.7, .5), -.5) # angle ranges from -.5 to .5

func _on_button(bname, state):
	if bname == "accel":
		print(bname + " - " + state)
		if state == "on":
			forward_acceleration = acceleration_strength
		else:
			forward_acceleration = -2 * acceleration_strength
	
	if bname == "shock" and state == "on":
		get_tree().reload_current_scene()

func _draw():
	draw_polygon( [Vector2(16, -32), Vector2(-16, -32), Vector2(0, 32)], [Color()] )
	if steering_wheel_angle != 0:
		var circle = -1 / sin(steering_wheel_angle * PI / 2) # f(0) = inf and f(1) = 0
		draw_circle( Vector2(circle, 0), 10, Color(0, 0, 0, .5))
	
	
	
	