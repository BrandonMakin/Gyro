extends ColorRect

onready var color_no_hover = get_frame_color()
onready var color_hover =  Color(0.957031, 0.919544, 0.869561)

func _process(delta):
	color = color_no_hover
	for cursor in $"../MenuObserver".get_children():
		if get_rect().has_point(cursor.position):
			color = color_hover
			break