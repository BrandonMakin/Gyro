extends InterpolatedCamera

export var id = 0

var world = null
var cam_offset
var lerp_amount = 5
var target_vehicle

var min_speed_FOV = 35
var max_speed_FOV = 60


func _ready():
	world = $"../../../../Level/Level 1"
	target_vehicle = world.get_node("vehicles/vehicle%s" % id)
	set_target(world.get_node("vehicles/vehicle%s/CamTarget" % id))
	cam_offset = get_node(target).transform.origin

func _process(delta): 
	global_transform.origin = get_node(target).get_parent().global_transform.origin + cam_offset
	cam_offset = cam_offset.linear_interpolate(get_node(target).global_transform.origin - get_node(target).get_parent().global_transform.origin, lerp_amount * delta)
	
	# Increase fov as you go faster.
	# NOTE that it uses speed_level, which isn't guaranteed to be linearly proportional to the player's actual speed
	# For fov to be exactly proportional to the actual speed, lerp by something like target_vehicle.speed_level / target_vehicle.max_speed, probably.
	fov = lerp(min_speed_FOV, max_speed_FOV, target_vehicle.speed_level) 