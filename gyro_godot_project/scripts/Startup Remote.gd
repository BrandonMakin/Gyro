"""
This script loads at the start of the game
and exists for the entirety of the game.
"""

extends HTTPRequest

var static_url_and_port = "http://ec2-54-193-74-3.us-west-1.compute.amazonaws.com:8000"
#var static_url_and_port = "http://localhost:8000"
var is_remote = true
var players = []
var port = 8001
var udp = PacketPeerUDP.new()
var server_pid
var qr
var DEADZONE_RADIUS = 0.05

func _ready():
	var err = udp.listen(port)
	if err != OK:
		print("Can't listen specified port")
	
	request(static_url_and_port + "/start")
	
func _process(delta):
	
	while(udp.get_available_packet_count() > 0):
		var packet = udp.get_packet().get_string_from_utf8()
		var code = packet.left(1)
		packet = packet.right(1)
		print("packet: " + str(packet))
		match code:
			"9":
				#print("pong")
				request(static_url_and_port + "/pong")
			"8":
				qr = packet
#				print(packet)
				print(qr)
#			"0":
#				get_tree().call_group("messengers", "_on_message", packet)
			"1": # On player connect
				players.append(packet)
				print("Global - players: " + str(players))
				get_tree().call_group("messengers", "_on_connect", packet)
			"2": # On player disconnect
				players.remove(players.find(packet))
				printerr(players)
				get_tree().call_group("messengers", "_on_disconnect", packet)
			"3": # On player phone button press
				var data = JSON.parse(packet).result #data contains i (id), n (name), and s (state)
				get_tree().call_group("messengers", "_on_button", data.i, data.n, data.s)
			"4": # On player phone rotation
				var data = JSON.parse(packet).result #data contains id, a (angle), and t (tilt)
				var angle = clean_angle_data(data.a)
				var tilt = clean_tilt_data(data.t)
				get_tree().call_group("messengers", "_on_rotate", data.id, angle, tilt)
			_:
				print("Unknown message: " + packet)

func clean_angle_data(angle):
	# PRECONDITION: angle ranges from -90 to 90
	angle /= 90
	angle = add_deadzone(angle)
	return angle
	# POSTCONDITION: angle ranges from -1 to 1,
	#	and there is a deadzone at plus or minus DEADZONE_RADIUS

func clean_tilt_data(tilt):
	# PRECONDITION: tilt ranges from 1 to 0
	tilt = (tilt * 2) - 1 - .2
	tilt = add_deadzone(tilt)
	return tilt
	# POSTCONDITION: tilt ranges from -1.2 (phone face-down) to 0.8 (phone face-up),
	#	and there is a deadzone at plus or minus DEADZONE_RADIUS

func add_deadzone(value):
	return 0 if (abs(value) < DEADZONE_RADIUS) else value