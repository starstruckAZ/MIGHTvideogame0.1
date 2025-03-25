extends Node

func _ready():
	print("Debug direct to main level script running")
	
	# Create a simple UI first to show we're working
	var canvas = CanvasLayer.new()
	add_child(canvas)
	
	var label = Label.new()
	label.text = "Attempting to load main level directly..."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(label)
	
	# Wait a moment before continuing
	await get_tree().create_timer(1.0).timeout
	
	# Try to access the MainLevel directly from the scene tree
	print("Accessing main level from scene tree")
	var main_level_path = "res://MainLevel.tscn"
	var main_level_scene = load(main_level_path)
	
	if main_level_scene:
		print("Successfully loaded MainLevel.tscn resource")
		var main_level_instance = main_level_scene.instantiate()
		
		# Clear current scene
		for child in get_children():
			if child != canvas:
				child.queue_free()
		
		# Add the MainLevel to our scene
		add_child(main_level_instance)
		label.text = "MainLevel loaded successfully!"
		
		# Make the label disappear after a delay
		var tween = create_tween()
		tween.tween_property(label, "modulate:a", 0.0, 2.0)
		await tween.finished
		canvas.queue_free()
	else:
		print("Failed to load main level resource")
		label.text = "Failed to load MainLevel.tscn\nCheck console for details"
		
		# Create emergency buttons
		var vbox = VBoxContainer.new()
		vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		vbox.position.y += 100  # Move down below the label
		canvas.add_child(vbox)
		
		var retry_button = Button.new()
		retry_button.text = "Retry"
		retry_button.pressed.connect(func(): get_tree().reload_current_scene())
		vbox.add_child(retry_button)
		
		var quit_button = Button.new()
		quit_button.text = "Quit"
		quit_button.pressed.connect(func(): get_tree().quit())
		vbox.add_child(quit_button)
