extends Node

#warning-ignore:unused_class_variable
var players = []
#warning-ignore:unused_class_variable
var game_id = ""

#warning-ignore:unused_signal
signal player_connected(player_id)
#warning-ignore:unused_signal
signal player_disconnected(player_id)
#warning-ignore:unused_signal
signal player_rotated(player_id, phone_angle, phone_tilt)
#warning-ignore:unused_signal
signal player_button_pressed(player_id, button_name, button_state)
#warning-ignore:unused_signal
signal color_scheme(player_id, scheme_id)

#var color_schemes = [
#	[Color("f59aa9"), Color("c74257"), Color()],
#	[Color(), Color(), Color()],
#	[Color(), Color(), Color()],
#	[Color(), Color(), Color()],
#	[Color(), Color(), Color()],
#	[Color(), Color(), Color()],
#	[Color(), Color(), Color()],
#	[Color(), Color(), Color()],
#]

#warning-ignore:unused_class_variable
var color_schemes = [
	Color("c74257"),
	Color("2e16b1"),
	Color("ffff00"),
	Color("00a779"),
	Color("cf78ff"),
	Color("00ffff"),
	Color("e7e7e7"),
	Color("222222"),
	Color("c54700"),
	Color("6be400"),
]