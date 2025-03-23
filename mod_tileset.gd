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
	
	# Get the TileSet
	var tileset = tilemap.tile_set
	if not tileset:
		print("TileMap has no TileSet.")
		return
	
	# Enable physics layer if it doesn't exist
	if tileset.get_physics_layers_count() == 0:
		tileset.add_physics_layer()
		tileset.set_physics_layer_collision_layer(0, 1) # Set collision layer to 1
	
	# Process all TileSetAtlasSources
	for source_id in tileset.get_source_ids():
		var source = tileset.get_source(source_id)
		if source is TileSetAtlasSource:
			# Add collision to all tiles in the atlas
			for coords in source.get_tiles_count():
				var tile_pos = source.get_tile_id(coords)
				
				for alternative_id in source.get_alternative_tiles_count(tile_pos):
					var alt_id = source.get_alternative_tile_id(tile_pos, alternative_id)
					
					# Add physics properties if they don't exist
					if not source.get_tile_data(tile_pos, alt_id).get_collision_polygons_count(0):
						var tile_data = source.get_tile_data(tile_pos, alt_id)
						
						# Add default square collision polygon
						tile_data.set_collision_polygons_count(0, 1)
						var polygon = PackedVector2Array([
							Vector2(-8, -8),
							Vector2(8, -8),
							Vector2(8, 8),
							Vector2(-8, 8)
						])
						tile_data.set_collision_polygon_points(0, 0, polygon)
						
						print("Added collision to tile at ", tile_pos, " alternative ", alt_id)
	
	print("Completed adding collision to all tiles.")

# Helper function to find a node of specific type in the scene tree
func find_node_by_type(node, type_name):
	if node.get_class() == type_name:
		return node
	
	for child in node.get_children():
		var result = find_node_by_type(child, type_name)
		if result:
			return result
	
	return null 