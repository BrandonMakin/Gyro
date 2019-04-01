extends Node

#warning-ignore:unused_class_variable
var players = []

#warning-ignore:unused_signal
signal player_connected(player_id)
#warning-ignore:unused_signal
signal player_disconnected(player_id)
#warning-ignore:unused_signal
signal player_rotated(player_id, phone_angle, phone_tilt)
#warning-ignore:unused_signal
signal player_button_pressed(player_id, button_name, button_state)