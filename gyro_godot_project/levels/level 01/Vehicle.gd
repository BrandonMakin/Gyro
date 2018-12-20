tool
extends KinematicBody

var accel_speed = 10

var velocity = Vector3()
var acceleration = Vector3()
var desired_rotation = Vector3(0,0,0)

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
	velocity.x = angle * 45
#	print(tilt)
	velocity.y = (tilt) * -40

func _on_button(name, state): #3 possible names for a button: accel, shoot, shock
	#2 states for a button: on, off
	print("button: " + name + "! (" + state + ")")
	if name == "accel":
		if state == "on":
			acceleration = Vector3(0,0,-1).rotated(Vector3(0,1,0), rotation.y) * accel_speed
			print("acceleration: " + str(acceleration))
		else:
			acceleration.z = 0
	if name == "shock" and state == "on":
		get_tree().reload_current_scene()
	
func _physics_process(delta):
	velocity += acceleration * delta
	rotation.y += desired_rotation.y * delta

	var rot_y = desired_rotation.y
	desired_rotation.y = rotation.y
	rotation = rotation.linear_interpolate(desired_rotation, delta * 15)
	desired_rotation.y = rot_y

	move_and_slide(velocity)
	$CamTarget.rotation.x = -rotation.x # stabilize camera rotation
	$CamTarget.rotation.z = -rotation.z # stabilize camera rotation

func reset():
	print("RESET")
	desired_rotation = Vector3()
#	rotation = Vector3()
	velocity = Vector3()