extends Node

func _ready():
	print("=== Testing MainLevel loading ===")
	
	# Check if MainLevel.tscn exists
	var main_level_path = "res://MainLevel.tscn"
	print("Checking if " + main_level_path + " exists...")
	
	if ResourceLoader.exists(main_level_path):
		print("SUCCESS: " + main_level_path + " exists!")
		
		# Try to load it
		print("Attempting to load MainLevel.tscn...")
		var main_level_scene = load(main_level_path)
		
		if main_level_scene:
			print("SUCCESS: MainLevel.tscn loaded successfully!")
			
			# Try to instance it
			var main_level_instance = main_level_scene.instantiate()
			if main_level_instance:
				print("SUCCESS: MainLevel.tscn instantiated successfully!")
				main_level_instance.queue_free()
			else:
				print("ERROR: Failed to instantiate MainLevel.tscn")
		else:
			print("ERROR: Failed to load MainLevel.tscn")
	else:
		print("ERROR: " + main_level_path + " does not exist!")
		
		# Check alternative paths
		var alternative_paths = [
			"res://scenes/MainLevel.tscn",
			"res://levels/MainLevel.tscn",
			"res://Main.tscn"
		]
		
		print("Checking alternative paths...")
		for path in alternative_paths:
			if ResourceLoader.exists(path):
				print("Found MainLevel at alternative path: " + path)
	
	print("=== Testing complete ===")
	
	# After 2 seconds, try to load MainLevel directly
	await get_tree().create_timer(2.0).timeout
	print("Attempting to change scene to MainLevel.tscn...")
	var err = get_tree().change_scene_to_file("res://MainLevel.tscn")
	if err == OK:
		print("Scene change initiated successfully!")
	else:
		print("ERROR: Scene change failed with error code: " + str(err)) 