extends Node2D

var camera

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.position = Vector2(0, -260) # Include this line if using hit_lines_on_fish()
	camera = $"../../ViewportContainer/Viewport/Camera"
	camera.target_vehicle.connect("collision", self, "collision_animation")
	#warning-ignore:return_value_discarded
	$Sprite.connect("animation_finished", self, "animation_finished")

func collision_animation(collision, vehicle_position):
#	hit_lines_on_wall(collision, vehicle_position)
	hit_lines_on_fish(collision, vehicle_position)


func hit_lines_on_fish(collision, vehicle_position):
	$Sprite.play("default")
	if $Sprite.visible:
		return
	$Sprite.visible = true
	var target = camera.unproject_position(collision.position)
	position = camera.unproject_position(vehicle_position)
	look_at(target)

#func hit_lines_on_wall(collision, vehicle_position):
#	$Sprite.play("default")
#	if $Sprite.visible:
#		return
#	$Sprite.visible = true
#	var target = camera.unproject_position(vehicle_position)
#	position = camera.unproject_position(collision.position)
#	look_at(target)

func animation_finished():
	$Sprite.visible = false
	$Sprite.stop()
	$Sprite.frame = 0

#func _draw():
#	draw_line(-position, dir - position, Color(0,.5,.5), 10)
#	draw_circle(-position, 10, ColorN("red"))
#	draw_circle(pos_vehicle - position, 10, ColorN("violet"))