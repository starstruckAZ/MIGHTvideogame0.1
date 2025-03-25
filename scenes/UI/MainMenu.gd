extends Control

func _ready():
	# Ensure buttons are focused
	if has_node("VBoxContainer/StartButton"):
		$VBoxContainer/StartButton.grab_focus()
	
	# Play main menu music if AudioManager is available
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_music("main_menu")

func _on_start_button_pressed():
	# Play button click sound
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_sound("button_click", 1.0)
	
	# Load the main level
	get_tree().change_scene_to_file("res://MainLevel.tscn")

func _on_quit_button_pressed():
	# Play button click sound
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_sound("button_click", 1.0)
	
	# Quit the game
	get_tree().quit() 