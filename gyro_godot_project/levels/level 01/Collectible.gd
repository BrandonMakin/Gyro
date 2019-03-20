extends RigidBody

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered",self,"_on_body_enter")

# Called on collision with another object. 'body' is the colliding object
func _on_body_enter(body):
	if body.is_in_group("players"): #Using groups so this code only operates on players
		print("Collectible Obtained!")
		body.coins_collected += 1
		print("Collectibles collected: %d" % body.coins_collected)
		body.swim_state.max_speed += 5
		print("Max Speed: %d" % body.swim_state.max_speed)
		get_parent().remove_child(self)
	
