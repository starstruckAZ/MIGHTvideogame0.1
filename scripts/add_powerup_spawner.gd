@tool
extends EditorScript

func _run():
	# Open the MainLevel scene
	var main_level = load("res://MainLevel.tscn").instantiate()
	
	# Create PowerUpSpawner instance
	var powerup_spawner = load("res://scenes/PowerUpSpawner.tscn").instantiate()
	
	# Add the PowerUpSpawner to the MainLevel
	main_level.add_child(powerup_spawner)
	powerup_spawner.owner = main_level
	
	# Save the modified scene
	var packed_scene = PackedScene.new()
	packed_scene.pack(main_level)
	ResourceSaver.save(packed_scene, "res://MainLevel.tscn")
	
	print("Added PowerUpSpawner to MainLevel.tscn") 