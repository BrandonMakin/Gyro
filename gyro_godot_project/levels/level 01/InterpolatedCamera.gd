extends InterpolatedCamera

export var id = 0

var world = null
var cam_offset
var lerp_amount = 5


func _ready():
	world = $"../../../../Level 1"
	set_target(world.get_node("vehicles/vehicle%s/CamTarget" % id))
	cam_offset = get_node(target).transform.origin

func _process(delta): 
	global_transform.origin = get_node(target).get_parent().global_transform.origin + cam_offset
	cam_offset = cam_offset.linear_interpolate(get_node(target).global_transform.origin - get_node(target).get_parent().global_transform.origin, lerp_amount * delta)