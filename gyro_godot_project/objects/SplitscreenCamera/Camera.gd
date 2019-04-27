extends InterpolatedCamera

onready var id : int = $"../../..".id

var world = null
var cam_offset : Vector3
var lerp_amount : int = 5
var target_vehicle

var desired_fov
var min_speed_fov : int = 50
var max_speed_fov : int = 70 


func _ready():
	world = get_node("../../../../../..")
	#Camera target is dependent on camera ID
	target_vehicle = world.get_node("vehicles/vehicle%s" % id)
	set_target(world.get_node("vehicles/vehicle%s/CamTarget" % id))
	cam_offset = get_node(target).transform.origin
	#Sets initial camera position

func _process(delta): 
	global_transform.origin = get_node(target).get_parent().global_transform.origin + cam_offset
	cam_offset = cam_offset.linear_interpolate(get_node(target).global_transform.origin - get_node(target).get_parent().global_transform.origin, lerp_amount * delta)
	# Increase fov as you go faster.
	# NOTE that it uses speed_level, which isn't guaranteed to be linearly proportional to the player's actual speed
	# For fov to be exactly proportional to the actual speed, lerp by something like target_vehicle.speed_level / target_vehicle.max_speed, probably.
	desired_fov = lerp(min_speed_fov, max_speed_fov, target_vehicle.speed_level * target_vehicle.speed_level) 
	fov = lerp(fov, desired_fov, .1)
	
	if target_vehicle.speed_level > 1.2:
		$"../AnimatedSpeedlines".visible = true
	else:
		$"../AnimatedSpeedlines".visible = false