extends Control

@onready var progress_bar = $TextureProgressBar

func _ready():
	# Connect to the player health changed signal if we can find it
	var player = get_parent()
	if player and player.has_signal("health_changed"):
		player.health_changed.connect(_on_player_health_changed)
	
	# Try to connect to GameManager if it exists
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		if game_manager.has_signal("player_health_changed"):
			game_manager.player_health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(new_health, max_health = 100):
	# Update the progress bar
	if progress_bar:
		# Calculate percentage
		var percentage = (float(new_health) / float(max_health)) * 100.0
		progress_bar.value = percentage 