extends Node

var main_level_noui_script = preload("res://scripts/MainLevelNoUI.gd")
var main_level_scene_res = preload("res://MainLevel.tscn")

func _ready():
	print("Main scene starting") 
	
	# Hide the GameWorld initially
	$GameWorld.visible = false
	
	# Connect to the intro sequence signal that's already in the scene tree
	if has_node("IntroSequence"):
		print("Found IntroSequence node")
		$IntroSequence.sequence_completed.connect(_on_intro_sequence_completed)
	else:
		print("ERROR: IntroSequence node not found!")

func _on_intro_sequence_completed():
	print("Intro sequence completed - transitioning to main level") 
	
	# Gracefully remove intro sequence
	if has_node("IntroSequence"):
		var intro = $IntroSequence
		intro.queue_free()
	
	# Show a brief loading message
	var loading_label = Label.new()
	loading_label.text = "Loading game..."
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loading_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	loading_label.add_theme_font_size_override("font_size", 32)
	add_child(loading_label)
	
	# Give the engine a moment to process 
	await get_tree().process_frame
	
	# Try method 1: Direct instance from preloaded resource
	print("Loading MainLevel using preloaded resource...")
	var main_level = main_level_scene_res.instantiate()
	if main_level:
		# Attach our NoUI script
		main_level.set_script(main_level_noui_script)
		
		# Clear current scene and add MainLevel
		loading_label.queue_free()
		get_tree().root.add_child(main_level)
		get_tree().current_scene = main_level
		queue_free()
		return
	
	# If method 1 fails, use the other methods
	print("Checking if MainLevel.tscn exists...")
	var main_level_path = "res://MainLevel.tscn"
	if ResourceLoader.exists(main_level_path):
		print("MainLevel.tscn exists! Trying to load it...")
		
		# Method 2: Direct scene change
		print("Loading MainLevel.tscn using change_scene_to_file")
		var err = get_tree().change_scene_to_file(main_level_path)
		
		if err != OK:
			print("ERROR: Failed to load MainLevel.tscn directly, error code: " + str(err))
			
			# Method 3: Manual loading
			print("Trying manual loading method...")
			var main_level_scene = load(main_level_path)
			if main_level_scene:
				print("Successfully loaded MainLevel.tscn, instancing...")
				# Instance the scene
				var main_level_inst = main_level_scene.instantiate() 
				
				# Attach our NoUI script
				main_level_inst.set_script(main_level_noui_script)
				
				# Clear current scene and add MainLevel
				loading_label.queue_free()
				get_tree().root.add_child(main_level_inst)
				get_tree().current_scene = main_level_inst
				queue_free()
			else:
				print("ERROR: Failed to load MainLevel.tscn using load()")
				fallback_to_gameworld(loading_label)
		else:
			print("Successfully changed scene to MainLevel.tscn")
			loading_label.queue_free()
	else:
		print("ERROR: MainLevel.tscn does not exist at path: " + main_level_path)
		fallback_to_gameworld(loading_label)

func fallback_to_gameworld(loading_label):
	# Try loading from the GameWorld node as last fallback
	if has_node("GameWorld/MainLevel"):
		print("Using MainLevel from GameWorld instead")
		loading_label.queue_free()
		$GameWorld.visible = true
	else:
		loading_label.text = "Error loading game. Please restart."
		print("CRITICAL ERROR: Could not find MainLevel scene")
		return 