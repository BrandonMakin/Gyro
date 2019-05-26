extends AnimationPlayer

func _ready():
	yield(get_tree().create_timer(.5), "timeout")
	play("Stoplight")

func let_the_fish_swim():
	for fish in $"../../../vehicles".get_children():
		fish.change_state("Swimming")
	$"../../../Lap Marker".race_start()