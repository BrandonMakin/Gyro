extends AnimationPlayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	play("Stoplight")

func let_the_fish_swim():
	for fish in $"../../../vehicles".get_children():
		fish.change_state("Swimming")