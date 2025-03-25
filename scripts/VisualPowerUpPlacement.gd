extends Node2D

# PowerUp scene and class
const POWERUP_SCENE = preload("res://scenes/PowerUp.tscn")
const PowerUp = preload("res://scripts/PowerUp.gd")

# This script allows you to visibly place powerups in the editor
# and then converts them to actual powerups at runtime.
# The sprites are only visible in the editor, not during gameplay.

func _ready():
	# Convert all visual powerup sprites to actual powerups
	convert_visual_powerups()
	
	# Print information for debugging
	print("Visual PowerUp Placement system ready - converted editor sprites to actual powerups.")

func convert_visual_powerups():
	# Process each category of powerups
	process_node_group($HealthPowerUps)
	process_node_group($ShieldPowerUps)
	process_node_group($ProjectilePowerUps)

func process_node_group(group_node):
	if not group_node:
		return
		
	var count = 0
	# Process all child sprite nodes
	for sprite in group_node.get_children():
		if sprite is Sprite2D:
			# Create actual powerup at sprite position
			var powerup_type = sprite.get_meta("powerup_type")
			spawn_powerup(powerup_type, sprite.global_position)
			
			# Hide the editor sprite - it won't appear in the game
			sprite.visible = false
			count += 1
	
	print("Converted", count, "visual", group_node.name, "to actual powerups")

func spawn_powerup(type, position_vector):
	# Create a new powerup instance
	var powerup = POWERUP_SCENE.instantiate()
	
	# Set the powerup type
	powerup.set_type(type)
	
	# Set the position
	powerup.position = position_vector
	
	# Add the powerup to the level scene
	# We add to the parent of this node to ensure proper hierarchy
	get_parent().add_child(powerup)
	
	# Log spawn for debugging
	var type_names = ["Health", "Shield", "Projectile"]
	print("Spawned " + type_names[type] + " powerup at " + str(position_vector)) 