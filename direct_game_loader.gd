extends Node

func _ready():
	print("Direct game loader starting")
	print("OS: ", OS.get_name())
	print("Engine version: ", Engine.get_version_info())
	
	# Create a simple UI to show progress
	var label = Label.new()
	label.text = "Loading game..."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(label)
	
	# Wait a short moment to make sure everything is initialized
	await get_tree().create_timer(1.0).timeout
	
	# Try different paths to load the game - prioritize Main.tscn for proper intro sequence
	var paths_to_try = [
		"res://scenes/Main.tscn",
		"res://Main.tscn",
		"res://MainLevel.tscn",
		"res://scenes/MainLevel.tscn"
	]
	
	var success = false
	for path in paths_to_try:
		label.text = "Trying to load: " + path
		print("Trying to load: " + path)
		await get_tree().create_timer(0.5).timeout
		
		var err = get_tree().change_scene_to_file(path)
		if err == OK:
			print("Successfully loaded: " + path)
			success = true
			break
		else:
			print("Failed to load: " + path + ", error code: " + str(err))
	
	if not success:
		print("CRITICAL ERROR: All paths failed")
		label.text = "Failed to load game. Check console for details."
		
		# Create an emergency UI
		var vbox = VBoxContainer.new()
		vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		add_child(vbox)
		
		var retry_button = Button.new()
		retry_button.text = "Retry"
		retry_button.pressed.connect(func(): get_tree().reload_current_scene())
		vbox.add_child(retry_button)
		
		var quit_button = Button.new()
		quit_button.text = "Quit"
		quit_button.pressed.connect(func(): get_tree().quit())
		vbox.add_child(quit_button)
