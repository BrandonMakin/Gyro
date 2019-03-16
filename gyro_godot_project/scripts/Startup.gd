"""
This script loads at the start of the game
and exists for the entirety of the game.
"""

extends HTTPRequest

var static_url = "website"
var is_remote = true
var players = []
var port = 8001
var udp = PacketPeerUDP.new()
var server_pid
var qr
var DEADZONE_RADIUS = 0.05

func _ready():
	OS.center_window()
	print("LOOK HERE")
#	server_pid = OS.execute('../node_server/icon.png', [], true);
#	server_pid = OS.execute('node', [], false);
	
	
#	yield(start_local_server())
	#request("http://localhost:8000/qr")
	start();

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		OS.kill(server_pid)

func _process(delta):
	
	while(udp.get_available_packet_count() > 0):
		var packet = udp.get_packet().get_string_from_utf8()
		var code = packet.left(1)
		packet = packet.right(1)
		match code:
			"9":
				#print("pong")
				request("http://localhost:8000/pong")
			"8":
				qr = packet
#				print(packet)
				print(qr)
#			"0":
#				get_tree().call_group("messengers", "_on_message", packet)
			"1": # On player connect
				add_player(packet)
			"2": # On player disconnect
				players.remove(players.find(packet))
				printerr(players)
				get_tree().call_group("messengers", "_on_disconnect", packet)
			"3": # On player phone button press
				var data = JSON.parse(packet).result #data contains i (id), n (name), and s (state)
				
				# @TODO Remove the following check because it's probably slow.  Replace it with a different solution of resetting the server when the game starts.
				if not players.has(data.i):  # if this player isn't in the "players" dictionary, add them.
					add_player(data.i)
				
				get_tree().call_group("messengers", "_on_button", data.i, data.n, data.s)
			"4": # On player phone rotation
				var data = JSON.parse(packet).result #data contains id, a (angle), and t (tilt)
				
				# @TODO Remove the following check because it's probably slow.
				if not players.has(data.id):  # if this player isn't in the "players" dictionary, add them.
					add_player(data.id)
				
				var angle = clean_angle_data(data.a)
				var tilt = clean_tilt_data(data.t)
				get_tree().call_group("messengers", "_on_rotate", data.id, angle, tilt)
			_:
				print("Unknown message: " + packet)

func add_player(id):
	players.append(id)
	print("Global - players: " + str(players))
	get_tree().call_group("messengers", "_on_connect", id)

func start_local_server():
	match OS.get_name():
		"Windows":
			server_pid = OS.execute('../node_server/index-win.exe', PoolStringArray(), false);
		"OSX":
			#server_pid = OS.execute('../node_server/index-macos', PoolStringArray(), false);
			# type: node index.js
			pass
		"X11":
			server_pid = OS.execute('../node_server/index-linux', PoolStringArray(), false);
		_:
			print("Operating system not supported by the node server")

func start():
	var err = udp.listen(port)
	if err != OK:
		print("Can't listen specified port")

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