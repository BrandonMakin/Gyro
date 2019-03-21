extends Spatial

export(String) var START_STATE
var state_name : String
var current_state = null
var swim_state #Here so Collectible.gd has a guaranteed reference to swim_state to appropriately modify max_speed as necessary
var player_id : String
var coins_collected : int = 0
var is_drafting : bool = false
export(int) var drafting_timer_max = 100
var drafting_timer : int = drafting_timer_max

#variables that all states MIGHT need...
export(float) var speed_level = 0 # represents some the current speed at value from 0 to 1, before interpolation. 0 means not moving and 1 means moving at max speed,
								# ...but depending on your interpolation, the values in between may not correlate linearly to the speeds they represent. [no units, range: 0-1]
var state_stack : Array =  []

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("players")
	swim_state = get_node("States/Swimming")
	state_stack.push_front(START_STATE)
	state_name = state_stack[0]
	current_state = get_node("States/" + state_name)
	Global.connect("player_rotated", self, "_on_rotate")
	Global.connect("player_button_pressed", self, "_on_button")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_state._state_physics_process(delta)

#Called on phone rotation via player_rotated signal
func _on_rotate(id, angle, tilt):
	if id != player_id:
		return
	current_state._on_rotate(id, angle, tilt)

#Called on phone button press via player_button_pressed signal
func _on_button(id, angle, tilt):
	if id != player_id:
		return
	current_state._on_button(id, angle, tilt)

#Called when state needs to be changed
func change_state(state_name):
	current_state = get_node("States/" + state_name)
	
func reset_drafting_timer():
	drafting_timer = drafting_timer_max