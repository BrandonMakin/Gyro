extends InterpolatedCamera

export var id : int = 0

var world = null
var cam_offset : Vector3
var lerp_amount : int = 5
var target_vehicle

var min_speed_FOV : int = 50
var max_speed_FOV : int = 70 


func _ready():
	#Utilizing InterpolatedCamera's internal values to track the camera offset of the vehicle
	enabled = true
	speed = 10
	world = $"../../../../Level/Level 1"
	#Camera target is dependent on camera ID
	target_vehicle = world.get_node("vehicles/vehicle%s" % id)
	set_target(world.get_node("vehicles/vehicle%s/Fish/CamTarget" % id))
	cam_offset = get_node(target).transform.origin
	#Sets initial camera position
	global_transform.origin = get_node(target).get_parent().global_transform.origin + cam_offset

func _process(delta): 
	# Increase fov as you go faster.
	# NOTE that it uses speed_level, which isn't guaranteed to be linearly proportional to the player's actual speed
	# For fov to be exactly proportional to the actual speed, lerp by something like target_vehicle.speed_level / target_vehicle.max_speed, probably.
	fov = lerp(min_speed_FOV, max_speed_FOV, target_vehicle.speed_level * target_vehicle.speed_level) 