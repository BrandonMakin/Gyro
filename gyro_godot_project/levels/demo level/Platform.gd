tool
extends KinematicBody

var velocity = Vector3()
enum Vehicle {BIPLANE, UFO}
export(Vehicle) var vehicle_type = Vehicle.BIPLANE

func _enter_tree():
	$Biplane.visible = false
	$UFO.visible = false
	if vehicle_type == Vehicle.UFO:
		$UFO.visible = true
	else:
		$Biplane.visible = true

func _on_rotate(angle, tilt):
	rotation = Vector3((.6-tilt), 0, -angle/30)
	velocity.x = angle
	velocity.z = (tilt-.6) * -100
	print(tilt)

func _on_button(name, state):
	#do whatever you want
	pass
	
func _physics_process(delta):
	move_and_slide(velocity)