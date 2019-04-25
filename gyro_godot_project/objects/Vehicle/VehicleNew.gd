extends Node

var max_speed : int = 50  # [meters per second] 
const acceleration_strength : int = 7
export var sharpest_steering_radius : float = .1
export var speed : float = 0
var desired_rotation : Vector3 = Vector3(0,0,0)
var steering_wheel_angle : float = 0
var drifting_direction : float = 0
var min_drifting_speed_level : float = .2 # minimum fish_king.speed_level wherein drifting is still possible [no units, range: 0-1]
var min_drafting_speed_level : float = .5 # minimum fish_king.speed_level wherein drafting is allowed [no units, range: 0-1]
var is_side_drifting : bool = false
var shot_template = preload("res://art/models/projectile_standin.tscn")
onready var fish_king = $"../.."


export(int) var seconds_for_zero_to_max = 5 # time it takes to accelerate from zero to max_speed [seconds]
export(int) var seconds_for_max_to_zero = 5 # time it takes to brake from max_speed to zero [seconds]

enum MovementInputFlags {
	NO_INPUT = 0,
	ACCELERATING = 1,
	BRAKING = 2,
	ACCELERATING_AND_BRAKING = 3  # This equals the bitwise union of accelerating and braking, i.e. ACCELERATING_AND_BRAKING == ACCELERATING | BRAKING
	}
	
var current_movement_input = MovementInputFlags.BRAKING

#Called when phone is rotated from VehicleStateMachine
func _on_rotate(angle, tilt):
	desired_rotation = Vector3((-tilt), angle * 2, angle * 2)
	steering_wheel_angle = angle # max(min(angle*1.7, .5), -.5) # ranges from -.5 to .5

#Called when button is pressed from VehicleStateMachine
func _on_button(bname, state): #3 possible names for a button: accel, shoot, shock
	#2 states for a button: "on", "off"
	
#	print("button: " + name + "! (" + state + ")")
	
	#ACCEL button
	if bname == "accel": # set ACCELERATING bit of current_movement_input
		if state == "on":
			current_movement_input |= MovementInputFlags.ACCELERATING  # Add accelerating flag when player presses accelerate
			current_movement_input &= ~ MovementInputFlags.BRAKING  # Remove braking flag when player presses accelerate
		else:
			current_movement_input |= MovementInputFlags.BRAKING #Add braking flag when player isn't accelerating (For the vehicle to slow down)
			current_movement_input &= ~ MovementInputFlags.ACCELERATING #Remove accelerating flag when player isn't pressing accelerate
	
	#SHOCK button (But actually shoot)
	if bname == "shock" and state == "on":
		shoot()
		#get_tree().reload_current_scene()
	
	#SHOOT button (But actually drifting right now and probably going to become drifting)
	if bname == "shoot":
		if state == "on":
			start_drifting()
		else:
			stop_drifting()

#Called every frame this state is active from VehicleStateMachine
func _state_physics_process(delta):
	# Handle forward acceleration and braking. A player only accelerates if the player is not braking.
	if current_movement_input & MovementInputFlags.BRAKING == MovementInputFlags.BRAKING:  # check for BRAKING flag
		if fish_king.speed_level >= 0:
			fish_king.speed_level -= delta / seconds_for_max_to_zero # I think this is the correct way to make fish_king.speed_level go from 1 to 0 in seconds_for_max_to_zero seconds, but I'm not sure.
		else:
			 fish_king.speed_level = 0
		# Set the speed based on the fish_king.speed_level.  If you want to control the BRACKING acceleration curve, do it here:
		speed = fish_king.speed_level * max_speed
	
	elif current_movement_input & MovementInputFlags.ACCELERATING == MovementInputFlags.ACCELERATING: # else check for ACCELERATING flag
		
		#Apply drafting speed boost if necessary (120% at the moment).
		if fish_king.is_drafting && fish_king.speed_level > min_drafting_speed_level:
			if fish_king.speed_level < 1.2:
				fish_king.speed_level += 1.5 * (delta / seconds_for_zero_to_max) # Code stolen from below
		#If not drafting, deal with speed level normally
		elif fish_king.speed_level < 1:
			fish_king.speed_level += delta / seconds_for_zero_to_max  # I think this is the correct way to make fish_king.speed_level go from 0 to 1 in seconds_for_max_to_zero seconds, but I'm not sure.
		elif fish_king.speed_level > 1:
			fish_king.speed_level -= delta / seconds_for_max_to_zero # Code stolen from the braking bit flag
			

				
		# Set the speed based on the fish_king.speed_level.  If you want to control the ACCELERATING acceleration curve, do it here:
		speed = fish_king.speed_level * max_speed
			
	#Handle fish_king.rotation around x and z axes (these are directly based on how you hold the phone)

	fish_king.rotation.x = lerp(fish_king.rotation.x, desired_rotation.x, delta*15)
	#-desired_rotation.z here because the Fish model is backwards
	$"../../Fish".rotation.z = lerp($"../../Fish".rotation.z, -desired_rotation.z, delta*15)
	
	#handle fish_king.rotation around the y axis (this is the complex one) 
	if drifting_direction != 0 && fish_king.speed_level > min_drifting_speed_level:
		fish_king.rotation.y += .015 * drifting_direction
	fish_king.rotation.y -= steering_wheel_angle * delta / (2 * PI * sharpest_steering_radius)
	fish_king.move_and_slide(-fish_king.transform.basis.z * speed)

func reset():
	print("RESET")
	desired_rotation = Vector3()
	speed = 0

#Called when a player begins drifting, and rotates their model appropriately
func start_drifting():
	if sign(desired_rotation.y) != 0:
		is_side_drifting = true
		drifting_direction = sign(-1 * desired_rotation.y)
		$"../../Fish".rotation = Vector3(0, PI/5 * drifting_direction, $"../../Fish".rotation.z)

#Called when a player ceases drifting, and returns their model to normal
func stop_drifting():
	if (is_side_drifting):
		$"../../Fish".rotation = Vector3(0, 0, $"../../Fish".rotation.z)
		drifting_direction = 0
		is_side_drifting = false
		
#Called when a player is shooting another player.  One raycast per call
func shoot():
	var shot = shot_template.instance()
	var offset = -fish_king.transform.basis.z * 3
	print("FISH_KING: %s" % fish_king.global_transform.origin)
	shot.global_transform.origin = fish_king.global_transform.origin + offset
	shot.direction = -fish_king.transform.basis.z
	get_parent().add_child(shot)
#	var line_of_sight = $"../../ShootingLine"
#	var player_hit = line_of_sight.check_collision()
#	if player_hit:
#		print(player_hit.name + " HIT! by " + fish_king.name)
#		if player_hit.coins_collected > 0:
#			player_hit.coins_collected -= 1
#			print(player_hit.name + " lost a collectible from getting shot!")
#			player_hit.swim_state.max_speed -= 5 #subtract 5 from their max speed per coin lost
#		else:
#			print(player_hit.name + " didn't lose a collectible because they had 0")
#		print(player_hit.name + " Staggered!")
#		if player_hit.state_name == "Staggered":
#			player_hit.current_state.timer = 50 #Resets the timer to 50 if they're already staggered instead of pushing another stagger onto their state stack
#		else:
#			player_hit.push_state("Staggered") #Pushes Staggered to their state stack if they are hit and aren't already staggered
#	else:
#		print(fish_king.name + " shot missed")
	