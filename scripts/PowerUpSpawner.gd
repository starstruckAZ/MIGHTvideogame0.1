extends Node

# PowerUp scene and class
const POWERUP_SCENE = preload("res://scenes/PowerUp.tscn")
const PowerUp = preload("res://scripts/PowerUp.gd")

# Spawn settings
@export var powerup_count_per_type = 4  # Number of each type to spawn (doubled from 2 to 4)
@export var min_distance_between_powerups = 200.0  # Minimum distance between powerups
@export var edge_margin = 100.0  # Margin from level edges

# Level bounds for spawning - will be calculated in _ready
var level_bounds = Rect2()
var spawn_positions = []
var tilemap = null  # Reference to the tilemap

func _ready():
	# Calculate level bounds - the area where powerups can be spawned
	calculate_level_bounds()
	
	# Spawn powerups after a short delay to ensure everything is set up
	if is_inside_tree():
		var timer = get_tree().create_timer(0.5)
		timer.timeout.connect(_spawn_powerups)

func calculate_level_bounds():
	# Try to get level dimensions from the tilemap or other level elements
	var tilemaps = get_tree().get_nodes_in_group("tilemap")
	
	if tilemaps.size() > 0:
		tilemap = tilemaps[0]
		var tilemap_rect = tilemap.get_used_rect()
		var cell_size = tilemap.cell_size
		
		# Calculate bounds in world coordinates
		level_bounds.position = tilemap.map_to_world(tilemap_rect.position) + Vector2(edge_margin, edge_margin)
		level_bounds.end = tilemap.map_to_world(tilemap_rect.end) - Vector2(edge_margin, edge_margin)
	else:
		# Fallback to a reasonable size if no tilemap is found
		level_bounds = Rect2(Vector2(edge_margin, edge_margin), Vector2(2000 - edge_margin * 2, 1000 - edge_margin * 2))
		
	print("Level bounds for powerup spawns: ", level_bounds)

func _spawn_powerups():
	# Spawn each type of powerup
	for type in PowerUp.PowerUpType.values():
		for i in range(powerup_count_per_type):
			spawn_powerup(type)
			
	print("Spawned ", powerup_count_per_type * PowerUp.PowerUpType.size(), " powerups")

func spawn_powerup(type):
	# Create a new powerup instance
	var powerup = POWERUP_SCENE.instantiate()
	
	# Set the powerup type
	powerup.set_type(type)
	
	# Find a valid spawn position
	var spawn_pos = find_valid_spawn_position()
	powerup.position = spawn_pos
	
	# Add the powerup to the level
	add_child(powerup)
	
	# Remember this position
	spawn_positions.append(spawn_pos)
	
	# Log spawn
	var type_names = ["Health", "Shield", "Projectile"]
	print("Spawned ", type_names[type], " powerup at ", spawn_pos)

func find_valid_spawn_position():
	var attempts = 0
	var max_attempts = 100
	var spawn_pos = Vector2.ZERO
	var is_valid = false
	
	while !is_valid and attempts < max_attempts:
		# Generate random position within level bounds
		spawn_pos = Vector2(
			randf_range(level_bounds.position.x, level_bounds.end.x),
			randf_range(level_bounds.position.y, level_bounds.end.y)
		)
		
		# Check distance from other powerups
		is_valid = true
		for existing_pos in spawn_positions:
			if spawn_pos.distance_to(existing_pos) < min_distance_between_powerups:
				is_valid = false
				break
		
		# Check if position overlaps with a tile (ensure it's not inside terrain)
		if is_valid and tilemap != null:
			var tile_pos = tilemap.local_to_map(spawn_pos)
			var tile_data = tilemap.get_cell_tile_data(0, tile_pos)
			if tile_data != null:
				# A tile exists at this position
				is_valid = false
		
		attempts += 1
	
	if !is_valid:
		# If we couldn't find a valid position, try one more time with more aggressive parameters
		print("Warning: Could not find valid powerup position after ", max_attempts, " attempts. Trying with relaxed parameters...")
		
		# Try again with a higher position (to avoid being in tiles)
		spawn_pos = Vector2(
			randf_range(level_bounds.position.x, level_bounds.end.x),
			randf_range(level_bounds.position.y - 200, level_bounds.position.y - 100)  # Higher up from the ground
		)
		
		# Check if this position is valid (not overlapping tiles)
		if tilemap != null:
			var tile_pos = tilemap.local_to_map(spawn_pos)
			var tile_data = tilemap.get_cell_tile_data(0, tile_pos)
			if tile_data != null:
				# Still in a tile, move it up more
				spawn_pos.y -= 50
	
	return spawn_pos 
