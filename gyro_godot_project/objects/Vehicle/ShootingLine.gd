extends RayCast

func _ready():
    pass
	
func check_collision():
	if is_colliding():
		var body = get_collider()
		if body.is_in_group("players"): #Using groups so this code only operates on players
        	return body