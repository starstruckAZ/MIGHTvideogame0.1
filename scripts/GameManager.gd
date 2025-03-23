extends Node

# Autoload script for managing game state
var pause_menu_scene = preload("res://scenes/UI/PauseMenu.tscn")
var pause_menu_instance = null

var game_version = "v0.1.0"
var current_level = ""
var player_data = {
	"health": 100,
	"max_health": 100,
	"score": 0
}

func _ready():
	# Initialize the pause menu
	pause_menu_instance = pause_menu_scene.instantiate()
	add_child(pause_menu_instance)

func set_current_level(level_path):
	current_level = level_path
	
func get_player():
	return get_tree().get_first_node_in_group("player")

func restart_level():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func go_to_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")
	
func toggle_pause():
	if pause_menu_instance:
		pause_menu_instance.toggle_pause()

# Track game progress and achievements
func update_score(amount):
	player_data["score"] += amount
	
# Save and load game state
func save_game():
	var save_data = {
		"player": player_data,
		"current_level": current_level,
		"version": game_version
	}
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_data))
	
func load_game():
	if FileAccess.file_exists("user://savegame.save"):
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var json_string = save_file.get_line()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var save_data = json.get_data()
			player_data = save_data["player"]
			current_level = save_data["current_level"]
			
			# Load the saved level
			if current_level != "":
				get_tree().change_scene_to_file(current_level)
			
			return true
	
	return false 