extends Node

# HudTester.gd
# Attach this script to any node in your scene to test HUD functionality
# Great for debugging and verifying connections

@export var game_hud_path: NodePath

# References
var game_hud = null
var game_manager = null

# Test buttons
@onready var damage_button = $DamageButton
@onready var heal_button = $HealButton
@onready var add_score_button = $AddScoreButton

func _ready():
	# Find game manager
	game_manager = find_game_manager()
	
	# Find HUD
	if game_hud_path:
		game_hud = get_node(game_hud_path)
	else:
		game_hud = find_game_hud()
	
	# Create UI if running as standalone scene
	if get_children().size() == 0:
		create_test_ui()
	
	# Connect UI signals
	for child in get_children():
		if child.name == "DamageButton" and child.has_signal("pressed"):
			child.pressed.connect(on_damage_pressed)
		elif child.name == "HealButton" and child.has_signal("pressed"):
			child.pressed.connect(on_heal_pressed)
		elif child.name == "AddScoreButton" and child.has_signal("pressed"):
			child.pressed.connect(on_add_score_pressed)
	
	# Print debug info
	print("HUD Tester initialized")
	print("Game Manager found: ", game_manager != null)
	print("Game HUD found: ", game_hud != null)

func find_game_manager():
	# Try different paths where GameManager might be located
	var possible_paths = [
		"/root/GameManager",
		"../GameManager",
		"/root/Node2D/GameManager",
		"/root/Level/GameManager",
		"/root/Main/GameManager",
		"/root/MainLevel/GameManager"
	]
	
	for path in possible_paths:
		if has_node(path):
			return get_node(path)
	
	# Create a new game manager if none found
	var new_manager = Node.new()
	new_manager.name = "GameManager"
	new_manager.set_script(load("res://scripts/GameManager.gd"))
	add_child(new_manager)
	print("Created new GameManager for testing")
	return new_manager

func find_game_hud():
	# Try different paths where GameHUD might be located
	var possible_paths = [
		"/root/GameHUD",
		"../GameHUD",
		"/root/Node2D/GameHUD",
		"/root/Level/GameHUD",
		"/root/Main/GameHUD",
		"/root/MainLevel/GameHUD"
	]
	
	for path in possible_paths:
		if has_node(path):
			return get_node(path)
	
	print("ERROR: GameHUD not found in scene tree")
	return null

func create_test_ui():
	# Create damage button
	var dmg_btn = Button.new()
	dmg_btn.name = "DamageButton"
	dmg_btn.text = "Take Damage (-10)"
	dmg_btn.position = Vector2(50, 50)
	dmg_btn.size = Vector2(200, 50)
	dmg_btn.pressed.connect(on_damage_pressed)
	add_child(dmg_btn)
	
	# Create heal button
	var heal_btn = Button.new()
	heal_btn.name = "HealButton"
	heal_btn.text = "Heal Player (+15)"
	heal_btn.position = Vector2(50, 120)
	heal_btn.size = Vector2(200, 50)
	heal_btn.pressed.connect(on_heal_pressed)
	add_child(heal_btn)
	
	# Create score button
	var score_btn = Button.new()
	score_btn.name = "AddScoreButton"
	score_btn.text = "Add Score (+50)"
	score_btn.position = Vector2(50, 190)
	score_btn.size = Vector2(200, 50)
	score_btn.pressed.connect(on_add_score_pressed)
	add_child(score_btn)

func on_damage_pressed():
	if game_manager:
		var current_health = game_manager.player_health
		var new_health = max(current_health - 10, 0)
		game_manager.update_player_health(new_health)
		print("Player took damage. Health: ", new_health)
		
		# Play hit sound
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_sound("player_hit", 0.8)

func on_heal_pressed():
	if game_manager:
		var current_health = game_manager.player_health
		var max_health = game_manager.player_max_health
		var new_health = min(current_health + 15, max_health)
		game_manager.update_player_health(new_health)
		print("Player healed. Health: ", new_health)
		
		# Play heal sound
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_sound("health_pickup", 1.0)

func on_add_score_pressed():
	if game_manager:
		game_manager.add_score(50)
		print("Added score. Total: ", game_manager.score)
		
		# Play score sound
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_sound("score_increase", 1.0) 