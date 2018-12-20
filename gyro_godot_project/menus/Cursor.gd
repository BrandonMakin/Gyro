tool
extends Node2D

var color
onready var target_position = position
var speed = 1000
var velocity = Vector2()
var radius = 20

func _ready():
	randomize() # reseed random number generator 
	color = Color()
	
	color.v = 1
	color.s = .8
	color.h = randf()
	update()

func _process(delta):
	if (velocity.y > 0 and position.y + radius >= get_viewport_rect().size.y) \
	or (velocity.y < 0 and position.y - radius <= 0):
		velocity.y = 0
	
	if (velocity.x > 0 and position.x + radius >= get_viewport_rect().size.x) \
	or (velocity.x < 0 and position.x - radius <= 0):
		velocity.x = 0
	
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
	
	
	