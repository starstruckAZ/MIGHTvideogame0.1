extends "res://scripts/Enemy1.gd"

class_name Enemy2

# Enemy2 - Ranged attacker

# Projectile settings
@export var projectile_scene: PackedScene
@export var shoot_speed := 200.0
@export var shoot_cooldown := 1.5

# Reference to projectile spawn point
var projectile_spawn: Marker2D

func _ready():
	# Call the parent _ready function first
	super._ready()
	
	# Initialize Enemy2's properties
	max_health = 60  # Medium health for ranged attacker
	health = max_health
	attack_damage = 10
	move_speed = 65.0
	detection_radius = 300.0
	attack_range = 200.0  # Larger attack range for ranged enemy
	attack_cooldown = shoot_cooldown
	
	# Set custom animation properties
	frame_counts = {
		"idle": 4,
		"walk": 6,
		"attack1": 6,  # Renamed to match parent class
		"attack2": 6,  # Added to match parent class
		"take_hit": 3,
		"death": 7
	}
	
	animation_speeds = {
		"idle": 8,
		"walk": 10,
		"attack1": 12,  # Renamed to match parent class
		"attack2": 12,  # Added to match parent class
		"take_hit": 8,
		"death": 8
	}
	
	# Get projectile spawn point
	projectile_spawn = get_node_or_null("ProjectileSpawn")
	if !projectile_spawn:
		print("ERROR: ProjectileSpawn marker not found on Enemy2")
		# Create a default spawn point if missing
		projectile_spawn = Marker2D.new()
		projectile_spawn.name = "ProjectileSpawn"
		projectile_spawn.position = Vector2(30, 0)
		add_child(projectile_spawn)

# Override the parent attack function
func attack():
	# Start attack cooldown
	can_attack = false
	attack_timer = attack_cooldown
	
	# Handle attack combo similar to parent
	if attack_combo > 0 and attack_combo_timer > 0:
		attack_combo = (attack_combo % 2) + 1  # Toggle between 1 and 2
	else:
		attack_combo = 1
	
	attack_combo_timer = attack_combo_timeout
	
	# Try to load projectile scene if it's null
	if not projectile_scene:
		if ResourceLoader.exists("res://scenes/Projectile.tscn"):
			projectile_scene = load("res://scenes/Projectile.tscn")
		elif ResourceLoader.exists("res://scenes/effects/Projectile.tscn"):
			projectile_scene = load("res://scenes/effects/Projectile.tscn")
	
	# Update projectile spawn position based on facing direction
	if projectile_spawn:
		projectile_spawn.position.x = abs(projectile_spawn.position.x) if facing_right else -abs(projectile_spawn.position.x)
	
	# Spawn projectile if scene is set
	if projectile_scene and projectile_spawn:
		var projectile = projectile_scene.instantiate()
		if is_inside_tree():
			get_tree().current_scene.add_child(projectile)
			
			# Set projectile position and direction
			projectile.global_position = projectile_spawn.global_position
			var direction = 1 if facing_right else -1
			projectile.direction = Vector2(direction, 0)
			projectile.speed = shoot_speed
			projectile.damage = attack_damage
			
			# Set projectile collision exceptions if needed
			projectile.add_collision_exception(self)
			
			print("Enemy2 fired projectile in direction: ", direction)
