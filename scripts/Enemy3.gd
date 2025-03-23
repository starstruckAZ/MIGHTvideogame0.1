extends "res://scripts/Enemy.gd"

class_name Enemy3

# Enemy3 - Teleporting enemy

# Teleport settings
@export var teleport_distance := 120.0
@export var teleport_cooldown := 5.0

# Teleport state management
var teleport_timer := 0.0
var can_teleport := true
var is_teleporting := false
var teleport_direction := Vector2.ZERO
var teleport_target_position := Vector2.ZERO

# Add teleporting state to enum
enum {
	TELEPORT_OUT = 100,
	TELEPORT_IN = 101
}

func _ready():
	# Call parent _ready first
	super._ready()
	
	# Initialize Enemy3's properties
	max_health = 40  # Lower health but more agile
	health = max_health
	attack_damage = 12
	move_speed = 110.0  # Faster movement
	detection_radius = 280.0
	attack_range = 70.0
	attack_cooldown = 1.2
	
	# Set custom animation properties
	frame_counts = {
		"idle": 4,
		"walk": 6,
		"attack1": 5,  # Changed to match parent class naming
		"attack2": 5,  # Added to match parent class
		"teleport_out": 4,
		"teleport_in": 4,
		"take_hit": 3,
		"death": 7
	}
	
	animation_speeds = {
		"idle": 8,
		"walk": 10,
		"attack1": 14,  # Changed to match parent class naming
		"attack2": 14,  # Added to match parent class
		"teleport_out": 10,
		"teleport_in": 10,
		"take_hit": 8,
		"death": 8
	}

func _physics_process(delta):
	# Handle teleport cooldown
	if !can_teleport:
		teleport_timer -= delta
		if teleport_timer <= 0:
			can_teleport = true
	
	# Only process parent physics if not teleporting
	if current_state != TELEPORT_OUT and current_state != TELEPORT_IN:
		super._physics_process(delta)
	else:
		# Handle teleport states
		match current_state:
			TELEPORT_OUT:
				# Wait for animation to complete before changing position
				pass
			TELEPORT_IN:
				# Wait for animation to complete before returning to chase
				pass

func process_chase_state(delta):
	# Call normal chase behavior from parent
	super.process_chase_state(delta)
	
	# Consider teleporting when chasing player
	if can_teleport and player and player_distance < detection_radius and randf() < 0.01:
		initiate_teleport()

func initiate_teleport():
	# Start teleport cooldown
	can_teleport = false
	teleport_timer = teleport_cooldown
	
	# Get player position if detected
	if player and player_distance < detection_radius:
		# Calculate teleport direction and target
		teleport_direction = (player.global_position - global_position).normalized()
		
		# Teleport behind the player
		teleport_target_position = player.global_position - teleport_direction * teleport_distance
		
		# Switch to teleport out state
		current_state = TELEPORT_OUT
		current_frame = 0
		animation_timer = 0
		
		# Disable collision during teleport
		set_collision_mask_value(1, false)
		set_collision_layer_value(2, false)

func teleport_complete():
	# Set position to target
	global_position = teleport_target_position
	
	# Switch to teleport in state
	current_state = TELEPORT_IN
	current_frame = 0
	animation_timer = 0
	
	# Re-enable collision after teleport
	set_collision_mask_value(1, true)
	set_collision_layer_value(2, true)

func attack():
	# Start attack cooldown
	can_attack = false
	attack_timer = attack_cooldown
	
	# Enable attack hitbox
	if attack_area:
		# Position attack area based on facing direction
		var attack_position = attack_area.position
		attack_position.x = abs(attack_position.x) if facing_right else -abs(attack_position.x)
		attack_area.position = attack_position
		
		# Enable collision shape
		if attack_area.has_node("CollisionShape2D"):
			attack_area.get_node("CollisionShape2D").disabled = false
		
		# Enable monitoring
		attack_area.monitoring = true
		attack_area.monitorable = true
		
		print("Enemy3 attack hitbox enabled at position:", attack_area.position)
		
		# Create a timer to disable the attack area after a short duration
		if is_inside_tree():
			var timer = get_tree().create_timer(0.3)  # 0.3 seconds attack duration
			timer.timeout.connect(func(): 
				if attack_area and is_instance_valid(attack_area):
					if attack_area.has_node("CollisionShape2D"):
						attack_area.get_node("CollisionShape2D").disabled = true
					attack_area.monitoring = false
			)

func handle_animation(delta):
	# Get animation based on current state
	var new_animation = ""
	
	match current_state:
		IDLE:
			new_animation = "idle"
		PATROL:
			new_animation = "walk"
		CHASE:
			new_animation = "walk"
		ATTACK:
			new_animation = "attack1"  # Changed to match parent class naming
		HURT:
			new_animation = "take_hit"
		DEATH:
			new_animation = "death"
		TELEPORT_OUT:
			new_animation = "teleport_out"
		TELEPORT_IN:
			new_animation = "teleport_in"
	
	# Update animation frame
	animation_timer += delta
	var frame_duration = 0.1 # Default frame duration
	
	if new_animation in animation_speeds:
		frame_duration = 1.0 / animation_speeds[new_animation]
	
	if new_animation != current_animation:
		current_animation = new_animation
		current_frame = 0
		animation_timer = 0
		
		if new_animation in frame_counts:
			frame_count = frame_counts[new_animation]
	
	if animation_timer >= frame_duration:
		animation_timer -= frame_duration
		current_frame += 1
		
		# Handle animation loop or end
		if current_frame >= frame_count:
			if current_animation == "death":
				# Don't loop death animation
				current_frame = frame_count - 1
				
				# Queue free after a delay to ensure animation completes
				if is_inside_tree():
					var death_timer = get_tree().create_timer(1.0)
					death_timer.timeout.connect(func(): queue_free())
			elif current_animation == "attack1" or current_animation == "attack2":
				# Switch back to chase after attack
				current_state = CHASE
				current_frame = 0
				
				# Disable attack area
				if attack_area:
					attack_area.monitoring = false
			elif current_animation == "take_hit":
				# Switch back to chase after hurt
				current_state = CHASE
				current_frame = 0
			elif current_animation == "teleport_out":
				# Teleport to target location
				teleport_complete()
			elif current_animation == "teleport_in":
				# Return to chase after teleport in
				current_state = CHASE
				current_frame = 0
			else:
				# Loop other animations
				current_frame = 0
	
	# Update sprite
	if sprite:
		sprite.frame = current_frame
		sprite.flip_h = !facing_right