extends CharacterBody2D

@export var SPEED = 60.0
@export var CHASE_SPEED = 110.0
@export var DETECT_RANGE = 300.0
@export var ATTACK_RANGE = 50.0
@export var PATROL_LEFT: float = 0.0
@export var PATROL_RIGHT: float = 200.0

var direction = -1
var player: Player = null
var state = Global.States.PATROL
var is_attacking = false
var lives = 2

@onready var sprite = $AnimatedSprite2D
@onready var hitbox: Area2D = $EnemyHitbox

func _physics_process(delta):

	if not is_on_floor():
		velocity.y += 800 * delta
	else:
		velocity.y = 0

	match state:
		Global.States.PATROL:
			patrol()
		Global.States.CHASE:
			chase()
		Global.States.ATTACK:
			attack()

	move_and_slide()
	_apply_facing()

func enemy():
	pass

func patrol():

	if global_position.x <= PATROL_LEFT:
		global_position.x = PATROL_LEFT
		direction = 1
	elif global_position.x >= PATROL_RIGHT:
		global_position.x = PATROL_RIGHT
		direction = -1

	velocity.x = direction * SPEED

	if sprite.animation != "walk":
		sprite.play("walk")


func chase():

	direction = sign(player.global_position.x - global_position.x)

	velocity.x = direction * CHASE_SPEED

	if sprite.animation != "walk":
		sprite.play("walk")

func attack():

	velocity.x = 0

	if is_attacking:
		return

	is_attacking = true
	sprite.play("attack")
	await sprite.animation_finished
	if player:
		player.lose_life()
	await get_tree().create_timer(0.3).timeout
	is_attacking = false


func _apply_facing():
	sprite.flip_h = direction > 0
	hitbox.scale.x = -1 if sprite.flip_h else 1


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		state = Global.States.CHASE


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player = null
		state = Global.States.PATROL


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		state = Global.States.ATTACK


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		state = Global.States.PATROL
		is_attacking = false

func freeze_player_on_hit():
	if player and player.has_method("freeze_player"):
		player.freeze_player(1.5)


func lose_lives(amount: int):
	lives -= amount
	print(lives)

	if lives <= 0:
		die()

func die():
	queue_free()
