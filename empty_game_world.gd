extends Node

func _ready():
	print("Empty game world creator running")
	
	# Create a simple UI first
	var canvas = CanvasLayer.new()
	add_child(canvas)
	
	var label = Label.new()
	label.text = "Creating empty game world..."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(label)
	
	# Wait a moment before continuing
	await get_tree().create_timer(1.0).timeout
	
	# Create a basic game world
	var game_world = Node2D.new()
	game_world.name = "GameWorld"
	add_child(game_world)
	
	# Try to load and add the Player scene
	var player_scene = load("res://scenes/Player.tscn")
	if player_scene:
		print("Successfully loaded Player scene")
		var player = player_scene.instantiate()
		player.position = Vector2(512, 300)  # Position in the center of screen
		game_world.add_child(player)
		label.text = "Player loaded successfully!"
	else:
		print("Failed to load Player scene")
		label.text = "Failed to create game world\nCheck console for details"
	
	# Make the label disappear after a delay
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 2.0)
	await tween.finished
	canvas.queue_free()
