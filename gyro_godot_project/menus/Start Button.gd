extends Control

onready var color_no_hover = Color(1,1,1)
onready var color_hover =  Color(0.099976, 0, 0.457031)

#warning-ignore:unused_argument
func _process(delta):
	modulate = color_no_hover
	for cursor in $"../MenuObserver".get_children():
		if get_rect().has_point(cursor.position):
			modulate = color_hover
			break