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
		if child.name.begins_with("Point"):
			existing_points.append(child)
	
	# Sort points by name to ensure proper order
	existing_points.sort_custom(func(a, b): return a.name < b.name)
	
	# Find the number of existing enemies
	var existing_enemies_count = enemies_container.get_child_count()
	print("Found " + str(existing_enemies_count) + " existing enemies.")
	
	# Get the last point number
	var last_point_number = existing_points.size()
	
	# Create vertical section patrol points
	var vertical_points = []
	var base_x = 1800  # X position for vertical section
	var heights = [100, 200, 300, 400, 500, 600]  # Different heights for vertical section
	
	print("Creating vertical section patrol points...")
	
	# Create vertical section patrol points
	for i in range(heights.size()):
		for j in range(2):  # 2 points at each height for patrol routes
			var point_number = last_point_number + 1 + (i * 2) + j
			var point = Marker2D.new()
			point.name = "VertPoint" + str(point_number)
			
			var x_offset = j * 200  # 200 pixels wide patrol route
			var point_x = base_x + x_offset
			
			point.position = Vector2(point_x, heights[i])
			patrol_points.add_child(point)
			point.owner = scene
			vertical_points.append(point)
			print("Added " + point.name + " at position " + str(point.position))
	
	# Add vertical section enemies
	var enemy_scenes = [
		"res://scenes/enemies/Enemy1.tscn",
		"res://scenes/enemies/Enemy2.tscn",
		"res://scenes/enemies/Enemy3.tscn"
	]
	
	print("Creating vertical section enemies...")
	
	for i in range(heights.size()):
		# Cycle through enemy types
		var enemy_type = i % 3
		var enemy_path = enemy_scenes[enemy_type]
		var enemy_name = "VertEnemy" + str(enemy_type + 1) + "_" + str(i)
		
		# Calculate which patrol points to use
		var point1 = vertical_points[i * 2].get_path()
		var point2 = vertical_points[i * 2 + 1].get_path()
		
		# Calculate position (midway between patrol points)
		var pos_x = (vertical_points[i * 2].position.x + vertical_points[i * 2 + 1].position.x) / 2
		var pos_y = vertical_points[i * 2].position.y
		
		# Create enemy
		var enemy_scene = load(enemy_path)
		if enemy_scene:
			var enemy = enemy_scene.instantiate()
			enemy.name = enemy_name
			enemy.position = Vector2(pos_x, pos_y)
			enemy.patrol_points = [point1, point2]
			enemies_container.add_child(enemy)
			enemy.owner = scene
			print("Added " + enemy_name + " at position " + str(enemy.position))
	
	print("Added " + str(heights.size()) + " vertical section enemies. Total enemies: " + str(enemies_container.get_child_count()))
	print("Vertical section setup complete!")

# Helper function to find a node by name in the scene tree
func find_node_by_name(node, name):
	if node.name == name:
		return node
	
	for child in node.get_children():
		var result = find_node_by_name(child, name)
		if result:
			return result
	
	return null 