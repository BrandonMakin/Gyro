extends Area

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	#warning-ignore:return_value_discarded
	connect("body_entered",self,"_on_body_enter")

# Called on physics body entering
func _on_body_enter(body):
	if body.is_in_group("players"): #Using groups so this code only operates on players
		print("DEBUG")
		body.speed_level = 1.5
		$"../Sound".play(0)