@tool
extends EditorScript

# Constants
const RAY_LENGTH = 100  # Length of ray to cast downward
const GROUND_OFFSET = 0  # Distance from ground to player's origin

func _run():
	# Get the currently edited scene
	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("No scene is currently open in the editor.")
		return
	
	# Find the Player node
	var player = find_node_by_name(scene, "Player")
	if not player:
		print("No Player found in the scene.")
		return
	
	# Create a temporary RayCast2D to use for testing
	var ray = RayCast2D.new()
	ray.enabled = true
	ray.target_position = Vector2(0, RAY_LENGTH)
	ray.collision_mask = 1  # Should match the tilemap's collision layer
	ray.name = "TemporaryRay"
	
	# Add the ray to the scene temporarily
	scene.add_child(ray)
	ray.global_position = player.global_position
	
	# Force the physics to update (need to manually position in the editor)
	ray.force_raycast_update()
	
	# Position player at the collision point if found
	if ray.is_colliding():
		var collision_point = ray.get_collision_point()
		player.global_position.y = collision_point.y - GROUND_OFFSET
		print("Adjusted player Y position to ", player.global_position.y)
	else:
		print("No collision detected below player. Manual adjustment may be required.")
		# Fallback to fixed position
		player.global_position.y = 552
		print("Set player to fallback Y position: 552")
	
	# Also adjust all enemies
	var enemies_container = find_node_by_name(scene, "Enemies")
	if enemies_container:
		for enemy in enemies_container.get_children():
			ray.global_position = enemy.global_position
			
			# Force raycast update
			ray.force_raycast_update()
			
			if ray.is_colliding():
				var collision_point = ray.get_collision_point()
				enemy.global_position.y = collision_point.y - GROUND_OFFSET
				print("Adjusted ", enemy.name, " Y position to ", enemy.global_position.y)
			else:
				print("No collision detected below ", enemy.name, ". Using fallback position.")
				enemy.global_position.y = 552
				print("Set ", enemy.name, " to fallback Y position: 552")
	
	# Adjust patrol points to match enemy heights
	var patrol_points = find_node_by_name(scene, "PatrolPoints")
	if patrol_points:
		for point in patrol_points.get_children():
			ray.global_position = point.global_position
			
			# Force raycast update
			ray.force_raycast_update()
			
			if ray.is_colliding():
				var collision_point = ray.get_collision_point()
				point.global_position.y = collision_point.y - GROUND_OFFSET
				print("Adjusted ", point.name, " Y position to ", point.global_position.y)
			else:
				point.global_position.y = 552
				print("Set ", point.name, " to fallback Y position: 552")
	
	# Remove the temporary ray
	ray.queue_free()
	
	print("Height adjustment complete!")

# Helper function to find a node by name in the scene tree
func find_node_by_name(node, name):
	if node.name == name:
		return node
	
	for child in node.get_children():
		var result = find_node_by_name(child, name)
		if result:
			return result
	
	return null 
