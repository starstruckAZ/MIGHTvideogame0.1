extends Node

func _ready():
	print("MainLevelNoUI script attached - removing UI elements")
	
	# Let the engine finish loading the scene
	call_deferred("_initialize")

func _initialize():
	# Wait one frame to ensure all nodes are properly initialized
	await get_tree().process_frame
	
	print("Initializing MainLevel with UI removal")
	
	# Find and disable any UI elements
	disable_ui_elements()
	
	# Set up player and game state
	setup_game()
	
	# Print a success message
	print("MainLevel loaded successfully!")

func disable_ui_elements():
	# Find UI nodes recursively and disable them
	print("Searching for UI elements to disable...")
	
	var disabled_count = 0
	
	# Try to find and disable the GameHUD specifically
	var game_hud = get_node_or_null("/root/GameHUD")
	if game_hud:
		print("Found and disabling root GameHUD")
		game_hud.visible = false
		disabled_count += 1
	
	# First try direct approach for CanvasLayers
	var ui_nodes = find_nodes_by_class("CanvasLayer")
	
	for ui_node in ui_nodes:
		if ui_node.name == "GameHUD" or "HUD" in ui_node.name or "UI" in ui_node.name:
			print("Disabling UI element: " + ui_node.name)
			ui_node.visible = false
			disabled_count += 1
	
	# Also look for common UI control elements
	var control_nodes = find_nodes_by_class("Control")
	for control in control_nodes:
		if ("health" in control.name.to_lower() or 
			"energy" in control.name.to_lower() or 
			"score" in control.name.to_lower() or
			"hud" in control.name.to_lower()):
			print("Disabling UI control: " + control.name)
			control.visible = false
			disabled_count += 1
	
	# If we're directly in MainLevel, look for specific UI nodes
	var health_bar = get_node_or_null("GameHUD/HealthBar") 
	if health_bar:
		health_bar.visible = false
		disabled_count += 1
	
	if disabled_count > 0:
		print("Successfully disabled " + str(disabled_count) + " UI elements")
	else:
		print("No UI elements found to disable")

func find_nodes_by_class(className, node = null):
	var result = []
	
	if node == null:
		node = get_tree().root
	
	if node.is_class(className):
		result.append(node)
	
	for child in node.get_children():
		var found = find_nodes_by_class(className, child)
		result.append_array(found)
	
	return result

func setup_game():
	# Find player if it exists
	var player = null
	
	# Look for a node that might be the player
	var potential_players = find_nodes_by_class("CharacterBody2D")
	for pot_player in potential_players:
		if "Player" in pot_player.name:
			player = pot_player
			break
	
	if player:
		print("Found player: " + player.name)
		# Initialize player if needed
		
	# Make sure game is unpaused
	get_tree().paused = false 
