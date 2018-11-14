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
	#server_pid = OS.execute('../node_server/icon.png', [], true);
	server_pid = OS.execute('../node_server/index-win.exe', PoolStringArray(), false);
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
		
		if (code == "9"):
			#print("pong")
			request("http://localhost:8000/pong")
		if (code == "8"):
			qr = packet
			print(qr)
		if (code == "0"):
			get_tree().call_group("messengers", "_on_message", packet)
		if (code == "1"):
			get_tree().call_group("messengers", "_on_connect", packet)
		if (code == "2"):
			get_tree().call_group("messengers", "_on_disconnect", packet)

func start():
	var err = udp.listen(port)
	if err != OK:
		print("Can't listen specified port")