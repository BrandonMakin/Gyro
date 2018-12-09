tool
extends KinematicBody

var velocity = Vector3()

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
	rotation = Vector3((.5-tilt), 0, -angle/30)
	velocity.x = angle / 2
#	print(tilt)
	velocity.y = (tilt-.5) * -40

func _on_button(name, state): #3 possible names for a button: accel, shoot, shock
	#2 states for a button: on, off
	print("button: " + name + "! (" + state + ")")
	if name == "accel":
		if state == "on":
			velocity.z = -10
		else:
			velocity.z = 0
	
func _physics_process(delta):
	move_and_slide(velocity)