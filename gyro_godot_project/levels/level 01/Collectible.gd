extends RigidBody

# Called when the node enters the scene tree for the first time.
func _ready():
	#warning-ignore:return_value_discarded
	connect("body_entered",self,"_on_body_enter")

# Called on collision with another object. 'body' is the colliding object
func _on_body_enter(body):
	if body.is_in_group("players"): #Using groups so this code only operates on players
		print("%s Collectible Obtained!" % body.name)
		if body.coins_collected < 10:
			body.coins_collected += 1
		print("%s Collectibles collected: %d" % [body.name, body.coins_collected])
		body.swim_state.max_speed += 5
		print("%s Max Speed: %d" % [body.name, body.swim_state.max_speed])
		get_parent().remove_child(self)
	
