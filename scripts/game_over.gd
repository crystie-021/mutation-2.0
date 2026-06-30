extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	$RestartBtn.pressed.connect(self._on_restart_pressed)


func show_game_over():
	visible = true
	get_tree().paused = true


func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")
