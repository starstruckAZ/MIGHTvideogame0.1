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
	
	# Create additional patrol points
	var new_points = []
	var last_point_number = existing_points.size()
	var point_spacing = 200  # Spacing between patrol points
	
	# Create new patrol points starting where the existing ones end
	var last_x = 0
	if existing_points.size() > 0:
		last_x = existing_points[existing_points.size() - 1].position.x
	else:
		last_x = 300  # Default starting position if no existing points
	
	# Calculate how many new points we need (2 per enemy, and we need 11 more enemies)
	var new_enemies_to_add = 14 - existing_enemies_count
	if new_enemies_to_add <= 0:
		print("Already have enough enemies, no need to add more.")
		return
	
	print("Adding " + str(new_enemies_to_add) + " new enemies.")
	
	# Create new patrol points
	for i in range(new_enemies_to_add * 2):
		var point_number = last_point_number + i + 1
		var point = Marker2D.new()
		point.name = "Point" + str(point_number)
		
		# Alternate x positions to create patrol paths
		var x_offset = i % 2 * point_spacing
		var point_x = last_x + 100 + x_offset
		
		# Every 4 points, move to a new area
		if i % 4 == 0 and i > 0:
			last_x += point_spacing * 2
			point_x = last_x
		
		# Vary y positions slightly for visual variety
		var y_variation = (randi() % 100) - 50  # -50 to +50 pixels
		
		point.position = Vector2(point_x, 300 + y_variation)
		patrol_points.add_child(point)
		point.owner = scene
		new_points.append(point)
		print("Added " + point.name + " at position " + str(point.position))
	
	# Add new enemies
	var enemy_scenes = [
		"res://scenes/enemies/Enemy1.tscn",
		"res://scenes/enemies/Enemy2.tscn",
		"res://scenes/enemies/Enemy3.tscn"
	]
	
	for i in range(new_enemies_to_add):
		# Cycle through enemy types
		var enemy_type = i % 3
		var enemy_path = enemy_scenes[enemy_type]
		var enemy_name = "Enemy" + str(enemy_type + 1) + "_" + str(i + existing_enemies_count)
		
		# Calculate which patrol points to use
		var point_index = i * 2
		var point1 = new_points[point_index].get_path()
		var point2 = new_points[point_index + 1].get_path()
		
		# Calculate position (midway between patrol points)
		var pos_x = (new_points[point_index].position.x + new_points[point_index + 1].position.x) / 2
		var pos_y = (new_points[point_index].position.y + new_points[point_index + 1].position.y) / 2
		
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
	
	print("Added " + str(new_enemies_to_add) + " new enemies. Total enemies: " + str(enemies_container.get_child_count()))
	print("Setup complete!")

# Helper function to find a node by name in the scene tree
func find_node_by_name(node, name):
	if node.name == name:
		return node
	
	for child in node.get_children():
		var result = find_node_by_name(child, name)
		if result:
			return result
	
	return null 
