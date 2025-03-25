extends SceneTree

# This is an editor script to add the Visual PowerUp Placement system to the MainLevel scene
# Run this script from Godot's Script Editor to add visual powerups

func _init():
	print("Adding Visual PowerUp Placement to MainLevel...")
	
	# Load the MainLevel scene
	var main_level_path = "res://MainLevel.tscn"
	var main_level_scene = load(main_level_path)
	
	if main_level_scene == null:
		print("ERROR: Could not load MainLevel scene at path: " + main_level_path)
		quit()
		return
	
	# Instance the MainLevel scene to edit it
	var main_level = main_level_scene.instantiate()
	
	# Load the VisualPowerUpPlacement scene
	var visual_powerups_scene = load("res://scenes/VisualPowerUpPlacement.tscn")
	if visual_powerups_scene == null:
		print("ERROR: Could not load VisualPowerUpPlacement scene")
		main_level.free()
		quit()
		return
	
	# Create an instance of the VisualPowerUpPlacement
	var visual_powerups = visual_powerups_scene.instantiate()
	
	# Add it to the MainLevel
	main_level.add_child(visual_powerups)
	visual_powerups.owner = main_level
	
	# Save the updated MainLevel scene
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(main_level)
	if result != OK:
		print("ERROR: Failed to pack the updated MainLevel scene")
		main_level.free()
		quit()
		return
	
	# Save the packed scene
	result = ResourceSaver.save(packed_scene, main_level_path)
	if result != OK:
		print("ERROR: Failed to save the updated MainLevel scene")
		main_level.free()
		quit()
		return
	
	print("Successfully added Visual PowerUp Placement to MainLevel!")
	print("You can now open MainLevel.tscn and visually position the powerup icons.")
	
	# Cleanup
	main_level.free()
	quit() 