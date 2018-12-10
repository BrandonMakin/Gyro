tool
extends Node2D

var color
onready var target_position = position
var speed = 1000
var velocity = Vector2()

func _ready():
	color = Color()
	
	color.v = 1
	color.s = .8
	color.h = randf()
	update()

func _process(delta):
	position += velocity * delta * speed

func _move(x, y):
	rotation = x * PI / 2
	velocity = velocity + (Vector2(x,y) - velocity) * .5

func _draw():
	# draw circle outline to add contrast:	
	draw_circle(Vector2(), 20, Color())
	draw_circle(Vector2(), 18, color.contrasted())
	draw_circle(Vector2(), 14, Color())
	# draw rest of cursor:
	draw_circle(Vector2(), 12, color)
	draw_line(- Vector2(14, 0), Vector2(14, 0), Color(), 6)
	draw_line(- Vector2(14, 0), Vector2(14, 0), color.contrasted(), 4)
	
	
	