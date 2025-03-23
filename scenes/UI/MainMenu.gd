extends Control

func _ready():
	# Ensure buttons are focused
	if has_node("VBoxContainer/StartButton"):
		$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed():
	# Load the main level
	get_tree().change_scene_to_file("res://MainLevel.tscn")

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit() 