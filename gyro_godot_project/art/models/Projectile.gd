extends KinematicBody

var direction : Vector3
var speed : float = 10

func _process(delta):
	var collision = move_and_collide(direction * speed)
	if(collision):
		var player_hit = collision.collider
		if player_hit.is_in_group("players"): #Using groups so this code only operates on players
			print(player_hit.name + " HIT!")
			if player_hit.coins_collected > 0:
				player_hit.coins_collected -= 1
				print(player_hit.name + " lost a collectible from getting shot!")
				player_hit.swim_state.max_speed -= 5 #subtract 5 from their max speed per coin lost
			else:
				print(player_hit.name + " didn't lose a collectible because they had 0")
			print(player_hit.name + " Staggered!")
			if player_hit.state_name == "Staggered":
				player_hit.current_state.timer = 50 #Resets the timer to 50 if they're already staggered instead of pushing another stagger onto their state stack
			else:
				player_hit.push_state("Staggered") #Pushes Staggered to their state stack if they are hit and aren't already staggered
		get_parent().remove_child(self)