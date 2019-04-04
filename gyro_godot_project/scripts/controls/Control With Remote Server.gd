"""
This script loads at the start of the game
and exists for the entirety of the game.
"""

extends HTTPRequest

var static_server_url = "ec2-54-193-74-3.us-west-1.compute.amazonaws.com"
var server_port = 8000
#var static_url_and_port = "http://ec2-54-193-74-3.us-west-1.compute.amazonaws.com:8000"
#var static_url_and_port = "http://localhost:8000"
#var is_remote = true
#var port = 8001
#var udp = PacketPeerUDP.new()
var tcp = StreamPeerTCP.new()
#var server_pid
var qr
var DEADZONE_RADIUS = 0.05

func _ready():
	
	OS.center_window()
#	var err = udp.listen(port)

	var err = tcp.connect_to_host(static_server_url, server_port)
	if err != OK:
		print("Can't connect to the remote server via TCP")
#
#	request(static_url_and_port + "/start")
	
#func _process(delta):
#	if tcp.get_available_bytes() > 0:
#		print(tcp.get_string(tcp.get_available_bytes()))

func _process(delta):
	
	while(tcp.get_available_bytes()) > 0:
		var packet = tcp.get_utf8_string(tcp.get_available_bytes())
		var code = packet.left(1)
		packet = packet.right(1)
		match code:
#			"9":
#				#print("pongeval $(/home/ec2-user/.linuxbrew/bin/brew shellenv)")
#				request(static_url_and_port + "/pong")
#			"8":
#				qr = packet
##				print(packet)
#				print(qr)
#			"0":
#				Global.emit_signal("_on_message", packet)
			"1": # On player connect
				Global.players.append(packet)
				print("Global - Global.players: " + str(Global.players))
				Global.emit_signal("player_connected", packet)
			"2": # On player disconnect
				Global.players.remove(Global.players.find(packet))
				printerr(Global.players)
				Global.emit_signal("player_disconnected", packet)
			"3": # On player phone button press
				var data = JSON.parse(packet).result #data contains i (id), n (name), and s (state)
				Global.emit_signal("player_button_pressed", data.i, data.n, data.s)
			"4": # On player phone rotation
				var data = JSON.parse(packet).result #data contains id, a (angle), and t (tilt)
				var angle = clean_angle_data(data.a)
				var tilt = clean_tilt_data(data.t)
				Global.emit_signal("player_rotated", data.id, angle, tilt)
			_:
				print("Unknown message with code ' " + code + " ': " + packet)
	
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