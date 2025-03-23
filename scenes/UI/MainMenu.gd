extends Control

func _ready():
	# Add a little animation to the title panel when the game starts
	$CenterContainer/VBoxContainer/TitlePanel.modulate.a = 0
	$CenterContainer/VBoxContainer/Buttons.modulate.a = 0
	
	var tween = create_tween()
	tween.tween_property($CenterContainer/VBoxContainer/TitlePanel, "modulate:a", 1.0, 0.5)
	tween.tween_property($CenterContainer/VBoxContainer/Buttons, "modulate:a", 1.0, 0.5)
	
	# Add hover animations to buttons
	for button in $CenterContainer/VBoxContainer/Buttons.get_children():
		if button is TextureButton:
			button.mouse_entered.connect(_on_button_hover.bind(button))
			button.mouse_exited.connect(_on_button_exit.bind(button))

func _on_button_hover(button):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)

func _on_button_exit(button):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

func _on_play_button_pressed():
	# Transition to game scene
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/TestLevel.tscn"))

func _on_options_button_pressed():
	# Options menu functionality
	print("Options menu not implemented yet")

func _on_credits_button_pressed():
	# Credits menu functionality
	print("Credits screen not implemented yet")

func _on_exit_button_pressed():
	# Exit game with a fade animation
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().quit()) 