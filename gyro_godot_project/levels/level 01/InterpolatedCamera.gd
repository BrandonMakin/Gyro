extends InterpolatedCamera

export var id = 0

var world = null

func _ready():
	if id == 1:
		world = $"../Level 1"
	elif id == 2:
		world = $"../../../ViewportContainer1/Viewport1/Level 1"

func _process(delta):
	set_target(world.get_node("vehicles/vehicle%s/CamTarget" % id))
