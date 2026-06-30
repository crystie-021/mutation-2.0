extends StaticBody2D

var falling = false
var rising = false
var start_y

@export var drop_distance = 42.0
@export var move_speed = 5.0
@export var wait_time = 3.0

func _ready():
	start_y = position.y
	falling = true

func _physics_process(delta):
	if falling:
		position.y += move_speed * delta

		if position.y >= start_y + drop_distance:
			position.y = start_y + drop_distance
			falling = false

			await get_tree().create_timer(wait_time).timeout
			rising = true

	elif rising:
		position.y -= move_speed * delta

		if position.y <= start_y:
			position.y = start_y
			rising = false

func _on_area_2d_body_entered(body):
	if body.has_method("lose_life"):
		body.lose_life()
