extends Node2D

# PowerUp scene and class
const POWERUP_SCENE = preload("res://scenes/PowerUp.tscn")
const PowerUp = preload("res://scripts/PowerUp.gd")

func _ready():
	# Place powerups at predefined positions in the level
	place_powerups()

func place_powerups():
	# Health powerups - doubled from 2 to 4
	spawn_powerup(PowerUp.PowerUpType.HEALTH, Vector2(400, 200))    # Very early in level
	spawn_powerup(PowerUp.PowerUpType.HEALTH, Vector2(2200, 300))   # Late in level
	spawn_powerup(PowerUp.PowerUpType.HEALTH, Vector2(800, 180))    # Early-mid level
	spawn_powerup(PowerUp.PowerUpType.HEALTH, Vector2(2600, 250))   # Very late in level
	
	# Shield powerups - doubled from 2 to 4
	spawn_powerup(PowerUp.PowerUpType.SHIELD, Vector2(1000, 150))   # On a high platform mid-level
	spawn_powerup(PowerUp.PowerUpType.SHIELD, Vector2(3000, 250))   # Near end of level
	spawn_powerup(PowerUp.PowerUpType.SHIELD, Vector2(1800, 220))   # Mid-level
	spawn_powerup(PowerUp.PowerUpType.SHIELD, Vector2(2400, 180))   # Late-mid level
	
	# Projectile powerups - doubled from 2 to 4
	spawn_powerup(PowerUp.PowerUpType.PROJECTILE, Vector2(1600, 200))  # Mid level
	spawn_powerup(PowerUp.PowerUpType.PROJECTILE, Vector2(2800, 350))  # Near end of level
	spawn_powerup(PowerUp.PowerUpType.PROJECTILE, Vector2(1200, 170))  # Early-mid level
	spawn_powerup(PowerUp.PowerUpType.PROJECTILE, Vector2(2100, 230))  # Late-mid level
	
	print("Placed 12 powerups across the level (doubled from 6)")

func spawn_powerup(type, position_vector):
	# Create a new powerup instance
	var powerup = POWERUP_SCENE.instantiate()
	
	# Set the powerup type
	powerup.set_type(type)
	
	# Set the position
	powerup.position = position_vector
	
	# Add the powerup to the level
	add_child(powerup)
	
	# Log spawn
	var type_names = ["Health", "Shield", "Projectile"]
	print("Spawned " + type_names[type] + " powerup at " + str(position_vector)) 