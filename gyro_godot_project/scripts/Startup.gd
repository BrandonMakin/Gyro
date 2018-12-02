"""
This script loads at the start of the game
and exists for the entirety of the game.
"""

extends HTTPRequest

var port = 8001
var udp = PacketPeerUDP.new()
var server_pid
var qr

func _ready():
	print("LOOK HERE")
#	server_pid = OS.execute('../node_server/icon.png', [], true);
#	server_pid = OS.execute('node', [], false);
	
	
	match OS.get_name():
		"Windows":
			server_pid = OS.execute('../node_server/index-win.exe', PoolStringArray(), false);
		"OSX":
			server_pid = OS.execute('../node_server/index-macos', PoolStringArray(), false);
		"X11":
			server_pid = OS.execute('../node_server/index-linux', PoolStringArray(), false);
		_:
			print("Operating system not supported by the node server")
	
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
				print(qr)
			"0":
				get_tree().call_group("messengers", "_on_message", packet)
			"1":
				get_tree().call_group("messengers", "_on_connect", packet)
			"2":
				get_tree().call_group("messengers", "_on_disconnect", packet)
			"3":
				var data = JSON.parse(packet).result #data contains i (id), n (name), and s (state)
				get_tree().call_group("messengers", "_on_button", data.i, data.n, data.s)
			_:
				print("Unknown message: " + packet)

func start():
	var err = udp.listen(port)
	if err != OK:
		print("Can't listen specified port")