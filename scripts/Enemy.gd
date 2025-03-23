extends CharacterBody2D
class_name Enemy

signal enemy_defeated

# Common enemy properties
var max_health = 800
var health = 800
var attack_damage = 10
var move_speed = 100.0
var detection_radius = 250.0
var attack_range = 50.0
var attack_cooldown = 1.5
var can_attack = true
var attack_timer = 0.0
var player = null
var player_distance = 0.0
var patrol_points = []
var current_patrol_point = 0
var facing_right = true

# Enemy state machine
enum {
	IDLE,
	PATROL,
	CHASE,
	ATTACK,
	HURT,
	DEATH
}

var current_state = IDLE

# Animation variables
var current_animation = ""
var current_frame = 0
var animation_timer = 0.0
var frame_count = 4

# References to child nodes
@onready var sprite = $Sprite2D
@onready var attack_area = $AttackArea
@onready var detection_area = $DetectionArea
@onready var hit_box = $HitBox

func _ready():
	# Set initial state
	current_state = IDLE
	
	# Setup attack timer
	attack_timer = attack_cooldown
	
	# Set collision layers and masks
	collision_layer = 4  # Enemy layer (3)
	collision_mask = 3   # Player (2) and world (1)
	
	# Setup detection area
	if has_node("DetectionArea"):
		var detection_area = get_node("DetectionArea")
		detection_area.collision_layer = 0
		detection_area.collision_mask = 2  # Player layer (2)
		
		if !detection_area.body_entered.is_connected(_on_detection_area_body_entered):
			detection_area.body_entered.connect(_on_detection_area_body_entered)
		if !detection_area.body_exited.is_connected(_on_detection_area_body_exited):
			detection_area.body_exited.connect(_on_detection_area_body_exited)
	
	# Setup attack area if it exists
	if has_node("AttackArea"):
		attack_area = get_node("AttackArea")
		attack_area.collision_layer = 0
		attack_area.collision_mask = 2  # Player layer (2)
		
		if attack_area.has_node("CollisionShape2D"):
			var shape = attack_area.get_node("CollisionShape2D")
			shape.disabled = true  # Start disabled
		
		attack_area.monitoring = false
		
		if !attack_area.body_entered.is_connected(_on_attack_area_body_entered):
			attack_area.body_entered.connect(_on_attack_area_body_entered)
	
	# Setup hit box (area for damaging player on contact)
	if has_node("HitBox"):
		var hit_box = get_node("HitBox")
		hit_box.collision_layer = 0
		hit_box.collision_mask = 2  # Player layer (2)
		
		if !hit_box.body_entered.is_connected(_on_hit_box_body_entered):
			hit_box.body_entered.connect(_on_hit_box_body_entered)
			print("Connected hit box signal")
	
	# Add to enemy group
	add_to_group("enemy")
	
	# Print collision setup
	print("Enemy collision setup:")
	print("Enemy layer: ", collision_layer)
	print("Enemy mask: ", collision_mask)
	
	# Initialize default values
	health = max_health
	
	# Start with random patrol point if any
	if patrol_points.size() > 0:
		current_patrol_point = randi() % patrol_points.size()

func _physics_process(delta):
	# Process state machine
	match current_state:
		IDLE:
			process_idle_state(delta)
		PATROL:
			process_patrol_state(delta)
		CHASE:
			process_chase_state(delta)
		ATTACK:
			process_attack_state(delta)
		HURT:
			process_hurt_state(delta)
		DEATH:
			process_death_state(delta)
	
	# Apply movement
	move_and_slide()
	
	# Prevent sticking to player by checking for collision
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("player"):
			# Don't apply damage here, we'll use HitBox for that
			# Just apply knockback to self to prevent sticking
			velocity = -collision.get_normal() * 200
	
	# Update attack cooldown
	if !can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true
	
	# Update player distance
	if player:
		player_distance = global_position.distance_to(player.global_position)
	
	# Handle animations
	handle_animation(delta)

func process_idle_state(delta):
	# In idle state, enemy stays still
	velocity = Vector2.ZERO
	
	# Randomly decide to start patrolling
	if patrol_points.size() > 0 and randf() < 0.01: # 1% chance each frame
		current_state = PATROL
	
	# Check if player is in detection range
	if player and player_distance < detection_radius:
		current_state = CHASE

func process_patrol_state(delta):
	# No patrol points? Go back to idle
	if patrol_points.size() == 0:
		current_state = IDLE
		return
	
	# Get current patrol point
	var target_point = get_node(patrol_points[current_patrol_point])
	if not target_point:
		current_state = IDLE
		return
	
	# Move towards patrol point
	var direction = global_position.direction_to(target_point.global_position)
	velocity = direction * move_speed
	
	# Update facing direction
	facing_right = velocity.x > 0
	
	# Check if reached patrol point
	if global_position.distance_to(target_point.global_position) < 10:
		# Move to next patrol point
		current_patrol_point = (current_patrol_point + 1) % patrol_points.size()
		
		# Wait at patrol point (idle temporarily)
		current_state = IDLE
	
	# Check if player is in detection range
	if player and player_distance < detection_radius:
		current_state = CHASE

func process_chase_state(delta):
	# If player lost, go back to patrol
	if not player or player_distance > detection_radius * 1.5:
		if patrol_points.size() > 0:
			current_state = PATROL
		else:
			current_state = IDLE
		return
	
	# Move towards player
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	
	# Update facing direction
	facing_right = velocity.x > 0
	
	# If in attack range, attack
	if player_distance < attack_range and can_attack:
		current_state = ATTACK
		attack()

func process_attack_state(delta):
	# Stop moving during attack
	velocity = Vector2.ZERO
	
	# Animation handles the return to chase state

func process_hurt_state(delta):
	# No movement while hurt
	velocity = Vector2.ZERO
	
	# Animation handles the return to chase state

func process_death_state(delta):
	# No movement when dead
	velocity = Vector2.ZERO
	
	# Wait for death animation to finish before removing

func attack():
	# Start attack cooldown
	can_attack = false
	attack_timer = attack_cooldown
	
	# Play attack sound
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sound("enemy_attack", 0.7, 0.9 + randf() * 0.2)
	
	# Enable attack hitbox
	if attack_area:
		# Make sure attack area is properly positioned
		var attack_position = attack_area.position
		attack_position.x = abs(attack_position.x) if facing_right else -abs(attack_position.x)
		attack_area.position = attack_position
		
		# Enable collision shape
		if attack_area.has_node("CollisionShape2D"):
			attack_area.get_node("CollisionShape2D").disabled = false
		
		# Enable monitoring
		attack_area.monitoring = true
		attack_area.monitorable = true
		
		print("Enemy attack hitbox enabled at position:", attack_area.position)
		
		# Create a timer to disable the attack area after a short duration
		if is_inside_tree():
			var timer = get_tree().create_timer(0.3)  # 0.3 seconds attack duration
			timer.timeout.connect(func(): 
				if attack_area and is_instance_valid(attack_area):
					if attack_area.has_node("CollisionShape2D"):
						attack_area.get_node("CollisionShape2D").disabled = true
					attack_area.monitoring = false
			)

func take_damage(amount, knockback_direction = Vector2.ZERO, knockback_strength = 200):
	print("Enemy taking ", amount, " damage!")
	if current_state == DEATH:
		print("Enemy already dead, ignoring damage")
		return
	
	health -= amount
	print("Enemy health: ", health, "/", max_health)
	
	# Play hit sound
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sound("enemy_hit", 0.8, 0.9 + randf() * 0.2)
	
	# Apply enhanced knockback
	if knockback_direction != Vector2.ZERO:
		# Add upward component for more visible knockback
		var enhanced_direction = Vector2(knockback_direction.x, min(knockback_direction.y, -0.3))
		enhanced_direction = enhanced_direction.normalized()
		
		# Apply the knockback
		velocity = enhanced_direction * knockback_strength
		
		# Add extra upward bounce for heavier hits
		if knockback_strength >= 250:
			velocity.y -= 100
	
	# Visual hit feedback
	modulate = Color(1.5, 1.5, 1.5)  # Flash white
	
	# Reset color after a short time
	if is_inside_tree():
		var reset_timer = get_tree().create_timer(0.1)
		reset_timer.timeout.connect(func(): modulate = Color(1, 1, 1))
	
	if health <= 0:
		print("Enemy killed!")
		# Instantly transition to death state
		current_state = DEATH
		
		# Play death sound
		if has_node("/root/AudioManager"):
			get_node("/root/AudioManager").play_sound("enemy_death", 1.0)
		
		# Final dramatic knockback on death
		velocity = velocity * 1.5
		
		# Disable all collisions
		set_collision_layer(0)
		set_collision_mask(0)
		
		# Disable collision shapes
		if has_node("CollisionShape2D"):
			get_node("CollisionShape2D").set_deferred("disabled", true)
		
		if has_node("HitBox"):
			get_node("HitBox").set_deferred("monitoring", false)
			get_node("HitBox").set_deferred("monitorable", false)
			if get_node("HitBox").has_node("CollisionShape2D"):
				get_node("HitBox").get_node("CollisionShape2D").set_deferred("disabled", true)
		
		# Emit the signal
		emit_signal("enemy_defeated", self)
		
		# Force queue_free after 1 second if animation doesn't trigger it
		if is_inside_tree():
			var timer = get_tree().create_timer(1.0)
			timer.timeout.connect(func(): queue_free())
	else:
		current_state = HURT

func die():
	current_state = DEATH
	print("Enemy died!")
	
	# Play death sound
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sound("enemy_death", 1.0)
	
	# Emit signal that enemy was defeated with self as parameter
	emit_signal("enemy_defeated", self)
	
	# Disable collision to prevent further interaction
	set_collision_layer(0)
	set_collision_mask(0)
	
	# Disable collision shapes
	if has_node("CollisionShape2D"):
		get_node("CollisionShape2D").set_deferred("disabled", true)
		print("Disabled main collision")
		
	if has_node("HitBox"):
		var hit_box = get_node("HitBox")
		if hit_box.has_node("CollisionShape2D"):
			hit_box.get_node("CollisionShape2D").set_deferred("disabled", true)
			print("Disabled HitBox collision")
	
	# Queue free immediately after a delay instead of waiting for animation
	if is_inside_tree():
		var death_timer = get_tree().create_timer(1.0)
		death_timer.timeout.connect(func(): queue_free())

# Default animation frame counts (can be overridden by child classes)
var frame_counts = {
	"idle": 4,
	"walk": 6,
	"attack1": 4,
	"attack2": 4,
	"take_hit": 3,
	"death": 7
}

# Default animation speeds
var animation_speeds = {
	"idle": 8,
	"walk": 10,
	"attack1": 12,
	"attack2": 14,
	"take_hit": 8,
	"death": 8
}

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
			new_animation = "attack1"
		HURT:
			new_animation = "take_hit"
		DEATH:
			new_animation = "death"
	
	# Update animation frame
	animation_timer += delta
	
	# Get frame duration from animation speeds or use default
	var frame_duration = 0.1 # Default frame duration
	if new_animation in animation_speeds:
		frame_duration = 1.0 / animation_speeds[new_animation]
	
	# If animation changed, update frame count and reset animation
	if new_animation != current_animation:
		current_animation = new_animation
		current_frame = 0
		animation_timer = 0
		
		# Get frame count for this animation
		if new_animation in frame_counts:
			frame_count = frame_counts[new_animation]
		else:
			frame_count = 4 # Default frame count
	
	# Update frame when timer exceeds frame duration
	if animation_timer >= frame_duration:
		animation_timer -= frame_duration
		current_frame += 1
		
		# Handle animation loop or end
		if current_frame >= frame_count:
			if current_animation == "death":
				# Don't loop death animation, just delete the enemy
				if is_inside_tree():
					queue_free()
				return
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
			else:
				# Loop other animations
				current_frame = 0
	
	# Update sprite
	if sprite:
		sprite.frame = current_frame
		sprite.flip_h = !facing_right

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body):
	if body == player:
		player = null

func _on_hit_box_body_entered(body):
	# Check if player has entered our hitbox
	if body.is_in_group("player") and body.has_method("take_damage"):
		# Only damage if not in cooldown
		if can_attack:
			var knockback_dir = (body.global_position - global_position).normalized()
			
			# Apply damage with position for knockback calculation in player
			body.take_damage(attack_damage, global_position)
			
			# Start a brief cooldown to prevent multiple hits at once
			can_attack = false
			attack_timer = 0.5  # Half second cooldown for body contact
			
			# Add visual feedback for the attack
			modulate = Color(1.2, 0.8, 0.8)  # Slight red tint during attack
			if is_inside_tree():
				var reset_timer = get_tree().create_timer(0.2)
				reset_timer.timeout.connect(func(): modulate = Color(1, 1, 1))

func _on_attack_area_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		# More powerful knockback from deliberate attacks
		var attack_position = global_position
		
		# Apply damage with more dramatic effects
		body.take_damage(attack_damage * 1.2, attack_position)  # 20% more damage from direct attacks
		
		# Apply slight recoil to the enemy
		var recoil_dir = (global_position - body.global_position).normalized()
		velocity += recoil_dir * 100
		
		# Visual attack feedback
		modulate = Color(1.3, 0.7, 0.7)  # More intense red tint
		if is_inside_tree():
			var reset_timer = get_tree().create_timer(0.3)
			reset_timer.timeout.connect(func(): modulate = Color(1, 1, 1))
		
		# Disable attack area immediately after hit
		if attack_area:
			attack_area.monitoring = false
