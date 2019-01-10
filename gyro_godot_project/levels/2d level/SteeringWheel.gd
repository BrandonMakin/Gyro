extends Node2D
var color

func _ready():
	randomize() # reseed random number generator 
	color = Color()
	
	color.v = 1
	color.s = .8
	color.h = randf()
	update()

func _draw():
# draw circle outline to add contrast:	
	draw_circle(Vector2(), 20, Color())
	draw_circle(Vector2(), 18, color.contrasted())
	draw_circle(Vector2(), 14, Color())
	# draw rest of cursor:
	draw_circle(Vector2(), 12, color)
	draw_line(- Vector2(14, 0), Vector2(14, 0), Color(), 6)
	draw_line(- Vector2(14, 0), Vector2(14, 0), color.contrasted(), 4)