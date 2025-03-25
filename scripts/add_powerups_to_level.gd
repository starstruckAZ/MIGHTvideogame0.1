extends SceneTree

func _init():
	print("Adding PowerUps to MainLevel...")
	
	# Create an instance of the PowerUps scene
	var powerups = load("res://scenes/ManualPowerUpPlacement.tscn").instantiate()
	
	# Add it to the main scene - this will be the current scene when the game runs
	get_root().get_child(0).add_child(powerups)
	
	# Exit the tool script
	quit() 
