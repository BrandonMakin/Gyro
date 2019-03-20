extends RigidBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered",self,"_on_body_enter")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_body_enter(body):
	#in the future, swap this for an if it's a vehicle, then go forth with the functions via tags or something (IDK How and this works)
	if body.is_in_group("players"): #It was colliding by default with a bunch of StaticBodies so I'm ignoring those collisions
		print("Collectible Obtained!")
		body.coins_collected += 1
		print("Collectibles collected: %d" % body.coins_collected)
		body.swim_state.max_speed += 5
		print("Max Speed: %d" % body.swim_state.max_speed)
		get_parent().remove_child(self)
	
