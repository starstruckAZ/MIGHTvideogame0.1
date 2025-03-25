@tool
extends EditorScript

func _run():
	# Get the currently edited scene
	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("No scene is currently open in the editor.")
		return
	
	# Find the Enemies container and PatrolPoints container
	var enemies_container = find_node_by_name(scene, "Enemies")
	if not enemies_container:
		print("Enemies container not found.")
		return
		
	var patrol_points = find_node_by_name(scene, "PatrolPoints")
	if not patrol_points:
		print("PatrolPoints container not found.")
		return
	
	# Get existing patrol points
	var existing_points = []
	for child in patrol_points.get_children():
		if child.name.begins_with("Point") or child.name.begins_with("VertPoint"):
			existing_points.append(child)
	
	# Find the number of existing enemies
	var existing_enemies_count = enemies_container.get_child_count()
	print("Found " + str(existing_enemies_count) + " existing enemies.")
	
	# Get the last point number
	var last_point_number = existing_points.size()
	
	# Create challenge section patrol points
	var challenge_points = []
	var base_x = 2500  # X position for challenge section
	var base_y = 300   # Base Y position for challenge section
	
	print("Creating challenge section patrol points...")
	
	# Create a grid of patrol points for complex patterns
	var grid_size = Vector2(3, 2)  # 3x2 grid
	var point_spacing = Vector2(300, 200)  # Spacing between points
	
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var point_number = last_point_number + 1 + (y * int(grid_size.x) + x)
			var point = Marker2D.new()
			point.name = "ChalPoint" + str(point_number)
			
			var point_x = base_x + (x * point_spacing.x)
			var point_y = base_y + (y * point_spacing.y)
			
			# Add random variation to points
			var rand_x = (randi() % 80) - 40
			var rand_y = (randi() % 60) - 30
			
			point.position = Vector2(point_x + rand_x, point_y + rand_y)
			patrol_points.add_child(point)
			point.owner = scene
			challenge_points.append(point)
			print("Added " + point.name + " at position " + str(point.position))
	
	# Define complex patrol paths for enemies
	var patrol_paths = [
		# First enemy - follows a rectangular path
		[0, 1, 4, 3, 0],
		# Second enemy - follows a diagonal path
		[0, 4, 1, 5, 0],
		# Third enemy - patrols the top row
		[0, 1, 2, 0],
		# Fourth enemy - patrols the bottom row
		[3, 4, 5, 3],
		# Fifth enemy - full zigzag pattern
		[0, 4, 1, 5, 2, 3, 0]
	]
	
	# Add challenge enemies
	var enemy_scenes = [
		"res://scenes/enemies/Enemy1.tscn",
		"res://scenes/enemies/Enemy2.tscn",
		"res://scenes/enemies/Enemy3.tscn"
	]
	
	print("Creating challenge section enemies...")
	
	for i in range(patrol_paths.size()):
		# Alternate between enemy types
		var enemy_type = i % 3
		var enemy_path = enemy_scenes[enemy_type]
		var enemy_name = "ChalEnemy" + str(enemy_type + 1) + "_" + str(i)
		
		# Get the patrol path for this enemy
		var path_indices = patrol_paths[i]
		var patrol_path = []
		
		# Convert indices to node paths
		for idx in path_indices:
			patrol_path.append(challenge_points[idx].get_path())
		
		# Calculate starting position (at the first patrol point)
		var start_pos = challenge_points[path_indices[0]].position
		
		# Create enemy
		var enemy_scene = load(enemy_path)
		if enemy_scene:
			var enemy = enemy_scene.instantiate()
			enemy.name = enemy_name
			enemy.position = start_pos
			enemy.patrol_points = patrol_path
			enemies_container.add_child(enemy)
			enemy.owner = scene
			print("Added " + enemy_name + " at position " + str(enemy.position) + " with " + str(patrol_path.size()) + " patrol points")
	
	print("Added " + str(patrol_paths.size()) + " challenge section enemies. Total enemies: " + str(enemies_container.get_child_count()))
	print("Challenge section setup complete!")

# Helper function to find a node by name in the scene tree
func find_node_by_name(node, name):
	if node.name == name:
		return node
	
	for child in node.get_children():
		var result = find_node_by_name(child, name)
		if result:
			return result
	
	return null 