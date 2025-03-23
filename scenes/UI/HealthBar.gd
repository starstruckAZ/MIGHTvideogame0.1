extends CanvasLayer

@onready var health_bar = $MarginContainer/InnerMargin/VBoxContainer/HealthBarContainer/HealthBar
@onready var dash_ready_label = $MarginContainer/InnerMargin/VBoxContainer/PlayerInfo/DashReadyLabel
@onready var special_ready_label = $MarginContainer/InnerMargin/VBoxContainer/PlayerInfo/SpecialReadyLabel

var player = null

func _ready():
	# Initialize status labels as invisible
	dash_ready_label.modulate.a = 0.0
	special_ready_label.modulate.a = 0.0
	
	# Find the player and connect to signals
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_player_health_changed)
		
		# Connect to additional player signals if they exist
		if player.has_signal("dash_ready_changed"):
			player.dash_ready_changed.connect(_on_dash_ready_changed)
		if player.has_signal("special_ready_changed"):
			player.special_ready_changed.connect(_on_special_ready_changed)

func _process(_delta):
	# Update status indicators based on player state even if signals aren't implemented
	if player:
		# Check dash cooldown
		if player.has_method("is_dash_ready"):
			_on_dash_ready_changed(player.is_dash_ready())
		elif "can_dash" in player:
			_on_dash_ready_changed(player.can_dash)
			
		# Check special ability (projectile at full health)
		if "current_health" in player and "max_health" in player:
			_on_special_ready_changed(player.current_health >= player.max_health)

func _on_player_health_changed(current_health, max_health):
	# Update the health bar value
	health_bar.value = (float(current_health) / max_health) * 100
	
	# Flash red when taking damage or pulse when health is low
	if health_bar.value < 30:
		# Low health - make it pulse
		var tween = create_tween()
		tween.tween_property(health_bar, "modulate", Color(1, 0.3, 0.3, 1), 0.2)
		tween.tween_property(health_bar, "modulate", Color(1, 1, 1, 1), 0.2)
	
	# Update special ready status
	_on_special_ready_changed(current_health >= max_health)

func _on_dash_ready_changed(is_ready):
	if is_ready:
		# Show dash ready indicator with animation
		var tween = create_tween()
		tween.tween_property(dash_ready_label, "modulate:a", 1.0, 0.3)
	else:
		# Hide dash ready indicator
		var tween = create_tween()
		tween.tween_property(dash_ready_label, "modulate:a", 0.0, 0.3)

func _on_special_ready_changed(is_ready):
	if is_ready:
		# Show special ready indicator with animation
		var tween = create_tween()
		tween.tween_property(special_ready_label, "modulate:a", 1.0, 0.3)
	else:
		# Hide special ready indicator
		var tween = create_tween()
		tween.tween_property(special_ready_label, "modulate:a", 0.0, 0.3) 