extends CanvasLayer

var is_paused = false

func _ready():
	# Hide pause menu at startup
	visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key by default
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	visible = is_paused
	
	if visible:
		# Add a slight animation when appearing
		$CenterContainer/PanelContainer.scale = Vector2(0.9, 0.9)
		var tween = create_tween()
		tween.tween_property($CenterContainer/PanelContainer, "scale", Vector2(1, 1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_resume_button_pressed():
	toggle_pause()

func _on_options_button_pressed():
	# Options menu functionality will go here
	# For now, just print a message
	print("Options menu not implemented yet")

func _on_main_menu_button_pressed():
	# Reset pause state
	get_tree().paused = false
	
	# Navigate to main menu scene
	# Assuming we have a main menu scene, replace the path if needed
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")

func _on_exit_button_pressed():
	# Quit the game
	get_tree().quit() 