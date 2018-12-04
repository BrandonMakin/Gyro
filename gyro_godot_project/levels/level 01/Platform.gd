extends KinematicBody

var velocity = Vector3()

func _ready():
	if randi() % 2 == 0:
		$Biplane.visible = false
		$UFO.visible = true

func _on_rotate(angle, tilt):
	rotation = Vector3((.6-tilt), 0, -angle/30)
	velocity.x = angle
	velocity.z = (tilt-.6) * -100
	print(tilt)
	
func _physics_process(delta):
	move_and_slide(velocity)