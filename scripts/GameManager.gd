extends Node

# Game state
var player_health := 100
var player_max_health := 100
var score := 0
var current_level := "MainLevel"
var is_game_over := false
var player_lives := 3

# Level info
var checkpoint_position = null

# Signals
signal player_health_changed(new_health, max_health)
signal score_changed(new_score)
signal player_died
signal game_over

# Scoring values
var enemy_score_values = {
	"Enemy1": 50,
	"Enemy2": 100,
	"Enemy3": 150
}

func _ready():
	# Make sure we're actually in the scene tree
	if not is_inside_tree():
		push_error("GameManager is not in scene tree!")
		return
	
	# Connect to autoloaded signals if needed
	# Example: SceneManager.level_loaded.connect(_on_level_loaded)
	
	# Connect to signals from enemies if they exist
	# This will catch newly instantiated enemies too
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node):
	# When an enemy is added to the scene, connect to its signals
	if node.is_in_group("enemy") and node.has_signal("enemy_defeated"):
		# Check if the signal is already connected to avoid duplicates
		if not node.enemy_defeated.is_connected(_on_enemy_defeated):
			node.enemy_defeated.connect(_on_enemy_defeated)

func _on_enemy_defeated(enemy):
	# Get enemy type from its name or scene
	var enemy_type = "Enemy"
	var enemy_name = enemy.name
	var scene_path = ""
	
	# Get the scene file path if available
	if enemy.has_method("get_scene_file_path"):
		scene_path = enemy.get_scene_file_path()
	elif enemy.has_method("get_filename"):
		scene_path = enemy.get_filename()
	
	# Determine enemy type
	if "Enemy1" in enemy_name or (scene_path != "" and "Enemy1" in scene_path):
		enemy_type = "Enemy1"
	elif "Enemy2" in enemy_name or (scene_path != "" and "Enemy2" in scene_path):
		enemy_type = "Enemy2"
	elif "Enemy3" in enemy_name or (scene_path != "" and "Enemy3" in scene_path):
		enemy_type = "Enemy3"
		
	# Get script name if available
	if enemy.get_script() and "Enemy1" in enemy.get_script().resource_path:
		enemy_type = "Enemy1"
	elif enemy.get_script() and "Enemy2" in enemy.get_script().resource_path:
		enemy_type = "Enemy2"
	elif enemy.get_script() and "Enemy3" in enemy.get_script().resource_path:
		enemy_type = "Enemy3"
	
	# Add score based on enemy type
	var points = enemy_score_values.get(enemy_type, 25)  # Default 25 points
	print("Enemy defeated: ", enemy_type, " - Points: ", points)
	add_score(points)

func update_player_health(new_health: int) -> void:
	player_health = new_health
	emit_signal("player_health_changed", player_health, player_max_health)
	
	if player_health <= 0 and !is_game_over:
		player_died.emit()
		player_lives -= 1
		
		if player_lives <= 0:
			is_game_over = true
			game_over.emit()

func add_score(points: int) -> void:
	score += points
	emit_signal("score_changed", score)
	
	# Check for score milestones
	if score % 500 == 0:
		# Bonus health for every 500 points
		player_health = min(player_health + 10, player_max_health)
		emit_signal("player_health_changed", player_health, player_max_health)

func player_death() -> void:
	player_died.emit()
	respawn_player()

func respawn_player() -> void:
	if player_lives > 0:
		# Respawn at checkpoint or level start
		if checkpoint_position != null:
			# Use checkpoint
			get_tree().reload_current_scene()
		else:
			# Restart level
			get_tree().reload_current_scene()
	else:
		# Game over
		is_game_over = true
		game_over.emit()
		# Show game over screen
		# await get_tree().create_timer(2.0).timeout
		# get_tree().change_scene_to_file("res://scenes/UI/GameOverScreen.tscn")

func restart_level() -> void:
	# Reset health but don't decrement lives
	player_health = player_max_health
	
	# Restart the current scene
	get_tree().reload_current_scene()

func set_checkpoint(position: Vector2) -> void:
	checkpoint_position = position

func reset_game() -> void:
	player_health = player_max_health
	score = 0
	player_lives = 3
	is_game_over = false
	checkpoint_position = null
	get_tree().change_scene_to_file("res://MainLevel.tscn") 