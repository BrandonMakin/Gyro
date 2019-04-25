extends Spatial

export(String) var START_STATE
#warning-ignore:unused_class_variable
export(int) var vehicle_number
var state_name : String
var current_state = null
var swim_state #Here so Collectible.gd has a guaranteed reference to swim_state to appropriately modify max_speed as necessary
var player_id : String
var coins_collected : int = 0
var is_drafting : bool

#variables that all states MIGHT need...
#warning-ignore:unused_class_variable
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
	#warning-ignore:return_value_discarded
	Global.connect("player_rotated", self, "_on_rotate")
	#warning-ignore:return_value_discarded
	Global.connect("player_button_pressed", self, "_on_button")
	is_drafting = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_state._state_physics_process(delta)

#Called on phone rotation via player_rotated signal
func _on_rotate(id, angle, tilt):
	if id != player_id:
		return
	current_state._on_rotate(angle, tilt)

#Called on phone button press via player_button_pressed signal
func _on_button(id, bname, state):
	if id != player_id:
		return
#	print("BUTTON! " + bname + ", " + state)	
	current_state._on_button(bname, state)

#Called when state needs to be changed
func change_state(new_state_name):
	current_state = get_node("States/" + new_state_name)

#Called when state needs to be pushed onto the state_stack
func push_state(new_state_name):
	state_stack.push_front(new_state_name)
	change_state(new_state_name)
	state_name = new_state_name
	
#called when state needs to be popped from the state_stack
func pop_state():
	if state_stack.size() == 1:
		print("ERROR: Trying to pop from STATE_STACK size 1")
	state_stack.pop_front()
	state_name = state_stack.front()
	change_state(state_name)
