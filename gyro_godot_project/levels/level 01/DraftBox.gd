extends Area

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered",self,"_on_body_enter")
	connect("body_exited",self,"_on_body_exit")

func _on_body_enter(body):
	if body.is_in_group("players"): #Using groups so this code only operates on players
		if body.name != get_parent().name:		#Code to check if the player isn't slipstreaming themself
			body.is_drafting = true


	
func _on_body_exit(body):
	if body.is_in_group("players"): #Using groups so this code only operates on players
		body.is_drafting = false #Doesn't need to check if the player is exiting their own box because vehicle will never exit its DraftBox
