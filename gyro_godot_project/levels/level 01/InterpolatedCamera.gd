extends InterpolatedCamera

export var id = 0

var world = null
var cam_offset
var lerp_amount = 5
var target_vehicle

var min_speed_FOV = 50 #Was 35 before I changed z offset of cameraTarget to 13 from 18
var max_speed_FOV = 70 


func _ready():
	#Utilizing InterpolatedCamera's internal values to track the camera offset of the vehicle
	enabled = true
	speed = 10
	world = $"../../../../Level/Level 1"
	target_vehicle = world.get_node("vehicles/vehicle%s" % id)
	set_target(world.get_node("vehicles/vehicle%s/Fish/CamTarget" % id))
	cam_offset = get_node(target).transform.origin
	global_transform.origin = get_node(target).get_parent().global_transform.origin + cam_offset

func _process(delta): 
	#OLD CAMERA CODE:
#	cam_offset = cam_offset.linear_interpolate(get_node(target).global_transform.origin - get_node(target).get_parent().global_transform.origin, lerp_amount * delta)

	# Increase fov as you go faster.
	# NOTE that it uses speed_level, which isn't guaranteed to be linearly proportional to the player's actual speed
	# For fov to be exactly proportional to the actual speed, lerp by something like target_vehicle.speed_level / target_vehicle.max_speed, probably.
	fov = lerp(min_speed_FOV, max_speed_FOV, target_vehicle.speed_level) 