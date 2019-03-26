"""
This script loads at the start of the game
and exists for the entirety of the game.
"""

extends Node

var id = "1337" # can be anything.
var players = []

var rotation = Vector2()

signal player_connected(player_id)
#signal player_disconnected(player_id)
signal player_rotated(player_id, phone_angle, phone_tilt)
signal player_button_pressed(player_id, button_name, button_state)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(false)
	OS.center_window()
	yield(get_tree().create_timer(1), "timeout")
	players.append(id)
	emit_signal("player_connected", id)
	set_process_input(true)

func _input(event):
	# drift aka shoot
	if Input.is_action_just_pressed("drift"):
			emit_signal("player_button_pressed", id, "shoot", "on")
	elif Input.is_action_just_released("drift"):
			emit_signal("player_button_pressed", id, "shoot", "off")
	
	# shock
	elif Input.is_action_just_pressed("shock"):
			emit_signal("player_button_pressed", id, "shock", "on")
	elif Input.is_action_just_released("shock"):
			emit_signal("player_button_pressed", id, "shock", "off")
	
	# accel
	elif Input.is_action_just_pressed("accel"):
			emit_signal("player_button_pressed", id, "accel", "on")
	elif Input.is_action_just_released("accel"):
			emit_signal("player_button_pressed", id, "accel", "off")
	
	# rotate
	if event is InputEventMouseMotion:
        rotation.x += event.relative.x * .001
        rotation.y += event.relative.y * .001
	emit_signal("player_rotated", id, rotation.x, rotation.y)