extends Node2D

@export var wall: NodePath

func _on_body_entered(body):
	if body.has_method("player"):
		get_node(wall).drop_wall()
