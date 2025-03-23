@tool
extends EditorScript

func _run():
	# Get the currently edited scene
	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("No scene is currently open in the editor.")
		return
	
	# Find the TileMap node
	var tilemap = find_node_by_type(scene, "TileMap")
	if not tilemap:
		print("No TileMap found in the scene.")
		return
	
	# Find the Player node
	var player = find_node_by_type(scene, "CharacterBody2D")
	if not player:
		print("No Player (CharacterBody2D) found in the scene.")
		return
	
	# Get the TileSet
	var tileset = tilemap.tile_set
	if not tileset:
		print("TileMap has no TileSet.")
		return
	
	# Check tile set physics layer
	if tileset.get_physics_layers_count() == 0:
		print("TileSet has no physics layers. Adding one...")
		tileset.add_physics_layer()
	
	# Make sure physics layer has collision layer 1
	tileset.set_physics_layer_collision_layer(0, 1)
	print("Set TileSet physics layer collision layer to 1")
	
	# Make sure physics layer has collision mask for layer 2 (player)
	tileset.set_physics_layer_collision_mask(0, 2)
	print("Set TileSet physics layer collision mask to 2 (player)")
	
	# Check player collision layer
	if player.collision_layer != 2:
		player.collision_layer = 2
		print("Set Player collision layer to 2")
	
	# Check player collision mask
	if player.collision_mask != 1:
		player.collision_mask = 1
		print("Set Player collision mask to 1 (environment)")
	
	# Process all TileSetAtlasSources to add collision
	for source_id in tileset.get_source_ids():
		var source = tileset.get_source(source_id)
		if source is TileSetAtlasSource:
			print("Processing TileSetAtlasSource ID: ", source_id)
			# Add collision to all tiles in the atlas
			for tile_index in range(source.get_tiles_count()):
				var tile_id = source.get_tile_id(tile_index)
				
				# Add physics for each alternative tile
				for alt_index in range(source.get_alternative_tiles_count(tile_id)):
					var alt_id = source.get_alternative_tile_id(tile_id, alt_index)
					var tile_data = source.get_tile_data(tile_id, alt_id)
					
					if tile_data.get_collision_polygons_count(0) == 0:
						# Add default square collision polygon
						tile_data.set_collision_polygons_count(0, 1)
						var polygon = PackedVector2Array([
							Vector2(-8, -8),
							Vector2(8, -8),
							Vector2(8, 8),
							Vector2(-8, 8)
						])
						tile_data.set_collision_polygon_points(0, 0, polygon)
						print("Added collision to tile ", tile_id, " alternative ", alt_id)
	
	# Update TileMap to use correct collision layer/mask
	tilemap.collision_animatable = true
	if tilemap.collision_layer != 1:
		tilemap.collision_layer = 1
		print("Set TileMap collision layer to 1")
	
	if tilemap.collision_mask != 0:
		tilemap.collision_mask = 0
		print("Set TileMap collision mask to 0")
	
	print("Collision layers/masks verification complete!")
	print("Please save the scene for changes to take effect.")

# Helper function to find a node of specific type in the scene tree
func find_node_by_type(node, type_name):
	if node.get_class() == type_name:
		return node
	
	for child in node.get_children():
		var result = find_node_by_type(child, type_name)
		if result:
			return result
	
	return null 