extends Spatial

var desired_rotation = Vector3(0,0,0);

#func _ready():
#	$"Remote Control".connect("rotate", self, "_rotate")

func rotated(x, y, z, w):
	var quat = Quat(x, y, z, w)
	var origin = transform.origin 
	transform = Transform(quat)
	transform.origin += origin
	#print(Transform(quat))


#func _process(delta):
#	pass