extends Node2D

@onready var wall = $Wall

func _on_wall_trigger_body_entered(body):
	if body.has_method("player"):
		wall.drop_wall()
