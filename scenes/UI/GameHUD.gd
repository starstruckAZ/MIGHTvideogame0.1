extends CanvasLayer

@onready var health_bar = $HealthContainer/HealthBar
@onready var energy_bar = $EnergyContainer/EnergyBar
@onready var score_value = $ScoreContainer/ScoreValue

# Cache the game manager reference
var game_manager

func _ready():
	# Try to find the GameManager at different possible locations
	find_game_manager()
	
	# If we have a game manager, connect to its signals
	if game_manager:
		if game_manager.has_signal("player_health_changed"):
			game_manager.player_health_changed.connect(_on_player_health_changed)
		if game_manager.has_signal("score_changed"):
			game_manager.score_changed.connect(_on_score_changed)
		
		# Set initial values
		update_health(game_manager.player_health, game_manager.player_max_health)
		update_score(game_manager.score)

func find_game_manager():
	# Try different paths where GameManager might be located
	var possible_paths = [
		"/root/GameManager",
		"../GameManager",
		"/root/Node2D/GameManager",
		"/root/Level/GameManager",
		"/root/MainLevel/GameManager"
	]
	
	for path in possible_paths:
		if has_node(path):
			game_manager = get_node(path)
			break

func update_health(new_health, max_health):
	# Update the health bar
	var percentage = (float(new_health) / float(max_health)) * 100.0
	health_bar.value = percentage
	
	# Update energy bar based on health (special attack availability)
	if new_health >= max_health:
		energy_bar.value = 100
		energy_bar.modulate = Color(1, 1, 1, 1)
	else:
		energy_bar.value = (float(new_health) / float(max_health)) * 100.0
		energy_bar.modulate = Color(1, 1, 1, 0.7)

func update_score(new_score):
	# Update the score display
	score_value.text = str(new_score)

# These are backup handlers if the direct signal connection didn't work
func _on_player_health_changed(new_health, max_health):
	update_health(new_health, max_health)

func _on_score_changed(new_score):
	update_score(new_score) 