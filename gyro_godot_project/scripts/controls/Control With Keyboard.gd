"""
This script loads at the start of the game
and exists for the entirety of the game.
"""

extends Node

var id = "1337" # can be anything.

var rotation = Vector2()

func _ready():
	print("Hey baby")
	OS.center_window()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(false)
	OS.center_window()
	yield(get_tree().create_timer(1), "timeout")
	Global.players.append(id)
	Global.emit_signal("player_connected", id)
	Global.emit_signal("color_scheme", id, 0)
	set_process_input(true)

func _input(event):
	# drift aka shoot
	if Input.is_action_just_pressed("drift"):
			Global.emit_signal("player_button_pressed", id, "shoot", "on")
	elif Input.is_action_just_released("drift"):
			Global.emit_signal("player_button_pressed", id, "shoot", "off")
	
	# shock
	elif Input.is_action_just_pressed("shock"):
			Global.emit_signal("player_button_pressed", id, "shock", "on")
	elif Input.is_action_just_released("shock"):
			Global.emit_signal("player_button_pressed", id, "shock", "off")
	
	# accel
	elif Input.is_action_just_pressed("accel"):
			Global.emit_signal("player_button_pressed", id, "accel", "on")
	elif Input.is_action_just_released("accel"):
			Global.emit_signal("player_button_pressed", id, "accel", "off")
	
	# rotate
	if event is InputEventMouseMotion:
		rotation += event.relative * .001
		rotation.x = min(max(rotation.x, -1), 1)
		rotation.y = min(max(rotation.y, -1.2), 0.8)
	Global.emit_signal("player_rotated", id, rotation.x, rotation.y)