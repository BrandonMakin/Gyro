extends Spatial

export(String) var START_STATE
var state_name
var current_state = null
var player_id

#variables that all states MIGHT need...
export(float) var speed_level = 0 # represents some the current speed at value from 0 to 1, before interpolation. 0 means not moving and 1 means moving at max speed,

var state_stack : Array =  []

# Called when the node enters the scene tree for the first time.
func _ready():
	state_stack.push_front(START_STATE)
	state_name = state_stack[0]
	current_state = get_node("States/" + state_name)
	Global.connect("player_rotated", self, "_on_rotate")
	Global.connect("player_button_pressed", self, "_on_button")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_state._state_physics_process(delta)

func _on_rotate(id, angle, tilt):
	if id != player_id:
		return
	current_state._on_rotate(id, angle, tilt)
	
func _on_button(id, angle, tilt):
	if id != player_id:
		return
	current_state._on_button(id, angle, tilt)
		
func change_state(state_name):
	current_state = get_node("States/" + state_name)