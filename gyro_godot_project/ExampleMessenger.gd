"""
-------------------------------------------------------------------------------
This is an example of a Messenger.
New Messengers should basically be formatted like this.

A Messenger is the thingy that waits runs code when player do stuff,
like rotating their phone or quitting the game.

All classes that inherit from this Messenger.gd must define these functions:

_on_connect(info):		Runs every time a new player connects

_on_disconnect(info):		Runs every time a player disconnects

_on_message(info):		Runs for all generic messages (like rotations)
-------------------------------------------------------------------------------
"""


extends Node

# member variables go here
# example: var foo

func _ready():
	add_to_group("messengers") # do not delete this line
	# initialization goes here
	# example: foo = 10
	pass

func _on_connect(msg):
	# runs every time a new player connects to the game
	pass

func _on_disconnect(msg):
	# runs every time a player disconnects from the game
	pass

func _on_message(msg):
	# runs for all generic messages (like rotations)
	pass

