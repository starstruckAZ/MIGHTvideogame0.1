@tool
extends EditorScript

func _run():
	# Get the currently edited scene
	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("No scene is currently open in the editor.")
		return
	
	# Rename root node if it's "Node2D" 
	if scene.name == "Node2D":
		scene.name = "Main"
	
	# Add ParallaxBackground if not already present
	var parallax = find_node_by_name(scene, "ParallaxBackground")
	if not parallax:
		var parallax_scene = load("res://parallaxbackground.tscn")
		if parallax_scene:
			parallax = parallax_scene.instantiate()
			scene.add_child(parallax)
			parallax.owner = scene
			print("Added ParallaxBackground")
	
	# Add Player if not already present
	var player = find_node_by_name(scene, "Player")
	if not player:
		var player_scene = load("res://scenes/Player.tscn")
		if player_scene:
			player = player_scene.instantiate()
			player.position = Vector2(100, 550)
			scene.add_child(player)
			player.owner = scene
			print("Added Player")
	
	# Add Enemies container if not already present
	var enemies_container = find_node_by_name(scene, "Enemies")
	if not enemies_container:
		enemies_container = Node2D.new()
		enemies_container.name = "Enemies"
		scene.add_child(enemies_container)
		enemies_container.owner = scene
		print("Added Enemies container")
	
	# Add PatrolPoints container if not already present
	var patrol_points = find_node_by_name(scene, "PatrolPoints")
	if not patrol_points:
		patrol_points = Node2D.new()
		patrol_points.name = "PatrolPoints"
		scene.add_child(patrol_points)
		patrol_points.owner = scene
		print("Added PatrolPoints container")
	
	# Add patrol points if they don't exist
	var points = []
	for i in range(1, 7):
		var point = find_node_by_name(patrol_points, "Point" + str(i))
		if not point:
			point = Marker2D.new()
			point.name = "Point" + str(i)
			point.position = Vector2(200 + (i * 100), 550)
			patrol_points.add_child(point)
			point.owner = scene
			print("Added Point" + str(i))
		points.append(point)
	
	# Add enemies if they don't exist
	var enemy_scenes = [
		{"path": "res://scenes/enemies/Enemy1.tscn", "name": "Enemy1", "position": Vector2(400, 550), "points": [points[0].get_path(), points[1].get_path()]},
		{"path": "res://scenes/enemies/Enemy2.tscn", "name": "Enemy2", "position": Vector2(600, 550), "points": [points[2].get_path(), points[3].get_path()]},
		{"path": "res://scenes/enemies/Enemy3.tscn", "name": "Enemy3", "position": Vector2(800, 550), "points": [points[4].get_path(), points[5].get_path()]}
	]
	
	for enemy_data in enemy_scenes:
		var enemy = find_node_by_name(enemies_container, enemy_data.name)
		if not enemy:
			var enemy_scene = load(enemy_data.path)
			if enemy_scene:
				enemy = enemy_scene.instantiate()
				enemy.name = enemy_data.name
				enemy.position = enemy_data.position
				enemy.patrol_points = enemy_data.points
				enemies_container.add_child(enemy)
				enemy.owner = scene
				print("Added " + enemy_data.name)
	
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