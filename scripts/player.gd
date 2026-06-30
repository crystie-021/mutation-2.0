extends CharacterBody2D
class_name Player

@onready var can_slash = true
@onready var can_dash = true
@onready var can_small_jump = true
@onready var can_long_jump = false
@onready var can_tongue = false
@onready var can_shell = false

@onready var heart_1: Panel = $Camera2D/UI/GridContainer/heart_1
@onready var heart_2: Panel = $Camera2D/UI/GridContainer/heart_2
@onready var heart_3: Panel = $Camera2D/UI/GridContainer/heart_3

@onready var hitbox: Area2D = $PlayerHitbox
var max_lives = 3
var lives = 3
var checkpoint_position = Vector2.ZERO

@export var SPEED = 150.0
@export var SMALL_JUMP_FORCE = -280.0
@export var LONG_JUMP_FORCE = -450.0
@export var DASH_SPEED = 500.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_busy = false
var is_shell = false
var facing = 1
var can_take_dmg = true
var is_frozen = false
var enemies: Array = []

var selected_btn: MutationBtn = null

@onready var sprite = $AnimatedSprite2D
@onready var shell_btn: MutationBtn = $Camera2D/UI/MutationButtons/MutationBtn
@onready var long_jump_btn: MutationBtn = $Camera2D/UI/MutationButtons/MutationBtn2
@onready var tongue_btn: MutationBtn = $Camera2D/UI/MutationButtons/MutationBtn3

func _ready():
	checkpoint_position = global_position
	if shell_btn:
		shell_btn.pressed.connect(self._on_shell_btn_pressed)
	if long_jump_btn:
		long_jump_btn.pressed.connect(self._on_long_jump_btn_pressed)
	if tongue_btn:
		tongue_btn.pressed.connect(self._on_tongue_btn_pressed)

func _on_shell_btn_pressed():
	selected_btn = shell_btn
	set_mutations_false()
	can_shell = true
	shell_btn.add_theme_stylebox_override("normal", preload("res://art/ui/button_selected.tres"))

func _on_long_jump_btn_pressed():
	selected_btn = long_jump_btn
	set_mutations_false()
	can_long_jump = true
	long_jump_btn.add_theme_stylebox_override("normal", preload("res://art/ui/button_selected.tres"))

func _on_tongue_btn_pressed():
	selected_btn = tongue_btn
	set_mutations_false()
	can_tongue = true
	tongue_btn.add_theme_stylebox_override("normal", preload("res://art/ui/button_selected.tres"))

func set_mutations_false():
	can_shell = false
	if shell_btn:
		shell_btn.add_theme_stylebox_override("normal", preload("res://art/ui/button_normal.tres"))
	can_long_jump = false
	if long_jump_btn:
		long_jump_btn.add_theme_stylebox_override("normal", preload("res://art/ui/button_normal.tres"))
	can_tongue = false
	if tongue_btn:
		tongue_btn.add_theme_stylebox_override("normal", preload("res://art/ui/button_normal.tres"))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_busy or is_shell:
		move_and_slide()
		return

	var dir = Input.get_axis("ui_left", "ui_right")

	if dir != 0:
		facing = sign(dir)
		velocity.x = dir * SPEED
		sprite.flip_h = dir < 0
		hitbox.scale.x = facing

		if is_on_floor():
			sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			sprite.play("idle")

	if Input.is_action_just_pressed("small_jump") and is_on_floor() and can_small_jump:
		velocity.y = SMALL_JUMP_FORCE
		play_action("small_jump")

	if Input.is_action_just_pressed("long_jump") and is_on_floor() and can_long_jump:
		velocity.y = LONG_JUMP_FORCE
		play_action("long_jump")

	if Input.is_action_just_pressed("dash") and can_dash:
		dash()

	if Input.is_action_just_pressed("tongue") and can_tongue:
		play_action("tongue")

	if Input.is_action_just_pressed("slash") and can_slash:
		slash()

	move_and_slide()


func _input(event: InputEvent) -> void:
	if can_shell:
		if event.is_action_pressed("shell") and not is_shell and not is_busy:
			enter_shell()
		elif event.is_action_released("shell") and is_shell:
			exit_shell()
	if event.is_action_pressed("one"):
		_on_shell_btn_pressed()
	if event.is_action_pressed("two"):
		_on_long_jump_btn_pressed()
	if event.is_action_pressed("three"):
		_on_tongue_btn_pressed()


func lose_life():
	if can_take_dmg and not is_shell:
		if lives == 3:
			$Camera2D/UI/GridContainer.remove_child(heart_3)
		elif lives == 2:
			$Camera2D/UI/GridContainer.remove_child(heart_2)
		elif lives == 1:
			$Camera2D/UI/GridContainer.remove_child(heart_1)
		can_take_dmg = false
		lives -= 1

	if lives <= 0:
		game_over()
	await get_tree().create_timer(0.5).timeout
	can_take_dmg = true


func respawn():
	global_position = checkpoint_position
	velocity = Vector2.ZERO
	is_busy = false
	is_shell = false


func set_checkpoint(pos):
	checkpoint_position = pos


func game_over():
	get_tree().paused = true
	$Camera2D/UI/GameOver.visible = true

func physics_process(delta):

	if not is_on_floor():
		velocity.y += gravity * delta

	if is_busy or is_shell:
		move_and_slide()
		return

	var dir = Input.get_axis("ui_left", "ui_right")

	if dir != 0:
		facing = sign(dir)
		velocity.x = dir * SPEED
		sprite.flip_h = dir < 0

		if is_on_floor():
			sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			sprite.play("idle")

	if Input.is_action_just_pressed("small_jump") and is_on_floor() and can_small_jump:
		velocity.y = SMALL_JUMP_FORCE
		play_action("small_jump")

	if Input.is_action_just_pressed("long_jump") and is_on_floor() and can_long_jump:
		velocity.y = LONG_JUMP_FORCE
		play_action("long_jump")

	if Input.is_action_just_pressed("dash") and can_dash:
		dash()

	if Input.is_action_just_pressed("tongue") and can_tongue:
		play_action("tongue")

	if Input.is_action_just_pressed("slash") and can_slash:
		play_action("slash")

	if Input.is_action_just_pressed("slash"):
		slash()

	move_and_slide()


func input(event: InputEvent) -> void:
	if event.is_action_pressed("shell") and not is_shell and not is_busy:
		enter_shell()
	elif event.is_action_released("shell") and is_shell:
		exit_shell()


func play_action(anim_name):
	is_busy = true
	sprite.play(anim_name)
	await sprite.animation_finished
	is_busy = false
	restore_move_anim()


func dash():
	is_busy = true
	sprite.play("dash_start")
	velocity.x = DASH_SPEED * facing
	await sprite.animation_finished
	sprite.play("dash_end")
	await sprite.animation_finished
	velocity.x = 0
	is_busy = false
	restore_move_anim()


func enter_shell():
	is_shell = true
	is_busy = true
	velocity = Vector2.ZERO
	sprite.play("shell")
	await sprite.animation_finished


func exit_shell():
	sprite.play("de_shell")
	await sprite.animation_finished
	is_shell = false
	is_busy = false
	restore_move_anim()


func restore_move_anim():
	if is_shell:
		return

	if abs(velocity.x) > 10 and is_on_floor():
		sprite.play("walk")
	else:
		sprite.play("idle")


func player():
	pass


func freeze_player(time):
	if is_frozen:
		return

	is_frozen = true
	is_busy = true
	velocity = Vector2.ZERO

	await get_tree().create_timer(time).timeout

	is_frozen = false
	is_busy = false

	restore_move_anim()


func slash():
	if is_busy or is_frozen:
		return

	is_busy = true
	sprite.play("slash")
	if not enemies.is_empty():
		for enemy in enemies:
			enemy.lose_lives(1)

	await sprite.animation_finished


	is_busy = false
	restore_move_anim()


func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemies.append(body)
		print(body.name, " entered")


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		print(body.name, " left")
		enemies.erase(body)
