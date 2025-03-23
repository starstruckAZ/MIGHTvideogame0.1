extends CharacterBody2D

# Add reference to Projectile class
const Projectile = preload("res://scripts/Projectile.gd")

# Player Constants
const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const ACCELERATION = 40.0
const FRICTION = 15.0
const DASH_SPEED = 850.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 1.5
const WALL_SLIDE_SPEED = 100.0
const WALL_JUMP_VELOCITY = Vector2(350, -350)
const GRAVITY_SCALE = 1.0
const GRAVITY = 980
const TERMINAL_VELOCITY = 600
const DOUBLE_JUMP_FACTOR = 0.9  # Second jump is 80% of normal height
const WALL_JUMP_COOLDOWN = 0.1

# Collision layers
const PLAYER_LAYER = 2
const ENEMY_LAYER = 4
const ENEMY_ATTACK_LAYER = 4
const WORLD_LAYER = 1

# Print collision layers for debugging (call in _ready)
func debug_collision_layers():
	print("PLAYER COLLISION SETUP:")
	print("Collision layer: ", collision_layer)
	print("Collision mask: ", collision_mask)
	if attack_area:
		print("AttackArea layer: ", attack_area.collision_layer)
		print("AttackArea mask: ", attack_area.collision_mask)

# Animation frame counts (override default)
var frame_counts = {
	"idle": 4,
	"run": 8,
	"jump": 2,
	"fall": 2,
	"attack1": 4,
	"attack2": 4,
	"take_hit": 3,
	"death": 7,
	"wall_slide": 2  # Using fall animation
}

# Animation speeds (frames per second)
var animation_speeds = {
	"idle": 8.0,
	"run": 12.0,
	"jump": 10.0,
	"fall": 10.0,
	"attack1": 16.0,
	"attack2": 16.0,
	"take_hit": 10.0,
	"death": 10.0,
	"wall_slide": 8.0  # Using fall animation
}

# Animation offsets
var animation_offsets = {
	"idle": Vector2(0, 0),
	"run": Vector2(0, 0),
	"jump": Vector2(0, 0),
	"fall": Vector2(0, 0),
	"attack1": Vector2(10, 0),
	"attack2": Vector2(12, 0),
	"take_hit": Vector2(0, 0),
	"death": Vector2(0, 0),
	"wall_slide": Vector2(0, 0)
}

# Player states
enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	DASH,
	HIT,
	DEATH,
	WALL_SLIDE
}

signal health_changed(current_health)
signal dash_ready_changed(is_ready)
signal special_ready_changed(is_ready)

# Movement variables
var current_state = PlayerState.IDLE
var is_attacking = false
var attack_combo = 0
var attack_combo_timeout = 0.5
var attack_combo_timer = 0
var can_dash = true
var dash_timer = 0
var dash_direction = Vector2.RIGHT
var is_dead = false
var can_double_jump = true
var can_wall_jump = true
var wall_jump_cooldown_timer = 0
var facing_right = true
var max_health = 100
var health = 100
var invincibility_time = 1.0
var is_invincible = false
var invincibility_timer = 0.0
var was_on_floor = false

# Animation variables
var current_animation = ""
var frame_count = 4
var current_frame = 0
var animation_timer = 0

# Get nodes
@onready var sprite = $Sprite2D
@onready var debug_label = $DebugLabel
@onready var attack_area = $AttackArea
@onready var dash_effect = $DashEffect
@onready var projectile_spawn = $ProjectileSpawn

# Projectile and effect properties
var projectile_scene = null
var dash_effect_scene = null  
var hit_effect_scene = null

func _ready():
	# Add player to the player group for collision detection
	add_to_group("player")
	
	# Set initial health
	health = max_health
	
	# Update GameManager health
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		game_manager.update_player_health(health)
	
	emit_signal("health_changed", health)
	emit_signal("dash_ready_changed", true)
	emit_signal("special_ready_changed", true)
	
	# Setup projectile spawn point if it doesn't exist
	if !has_node("ProjectileSpawn"):
		var spawn = Marker2D.new()
		spawn.name = "ProjectileSpawn"
		spawn.position = Vector2(40, -10)  # Adjust position as needed (right in front, slightly above center)
		add_child(spawn)
		projectile_spawn = spawn
		print("Created ProjectileSpawn node")
	else:
		projectile_spawn = get_node("ProjectileSpawn")
	
	# Setup attack area
	if has_node("AttackArea"):
		attack_area = get_node("AttackArea")
		print("Found attack area node")
		
		# Set collision layer and mask
		attack_area.collision_layer = 0  # Don't need a collision layer
		attack_area.collision_mask = 4  # Only detect enemies (layer 3)
		
		# Initialize attack area - enable only during attacks
		attack_area.monitoring = false
		attack_area.monitorable = false
		if attack_area.has_node("CollisionShape2D"):
			attack_area.get_node("CollisionShape2D").disabled = true
			print("Attack area collision shape ready")
		
		# Connect signal
		if !attack_area.body_entered.is_connected(_on_attack_area_body_entered):
			attack_area.body_entered.connect(_on_attack_area_body_entered)
			print("Attack area signal connected")
	else:
		print("WARNING: No AttackArea node found on Player!")
		# Try to create one
		attack_area = Area2D.new()
		attack_area.name = "AttackArea"
		var col_shape = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(40, 80)  # Reasonable attack area
		col_shape.shape = shape
		attack_area.add_child(col_shape)
		add_child(attack_area)
		attack_area.collision_layer = 0
		attack_area.collision_mask = ENEMY_LAYER
		attack_area.monitoring = false
		attack_area.monitorable = false
		col_shape.disabled = true
		attack_area.body_entered.connect(_on_attack_area_body_entered)
		print("Created new attack area")
	
	# Try to load resources if they exist
	if ResourceLoader.exists("res://scenes/enemies/ProjectileScene.tscn"):
		projectile_scene = load("res://scenes/enemies/ProjectileScene.tscn")
	elif ResourceLoader.exists("res://scenes/Projectile.tscn"):
		projectile_scene = load("res://scenes/Projectile.tscn")
	else:
		print("ERROR: Projectile.tscn not found!")
		
	# Use SlashEffect as DashEffect if available
	if ResourceLoader.exists("res://scenes/effects/SlashEffect.tscn"):
		dash_effect_scene = load("res://scenes/effects/SlashEffect.tscn")
	elif ResourceLoader.exists("res://scenes/effects/DashEffect.tscn"):
		dash_effect_scene = load("res://scenes/effects/DashEffect.tscn")
	else:
		print("WARNING: No dash effect found!")
		
	if ResourceLoader.exists("res://scenes/effects/HitEffect.tscn"):
		hit_effect_scene = load("res://scenes/effects/HitEffect.tscn")
	else:
		print("WARNING: HitEffect.tscn not found!")
	
	# Start at full health to allow using special immediately
	health = max_health
	
	# Debug collision setup
	debug_collision_layers()

func _physics_process(delta):
	# Debug info about attack area if currently attacking
	if current_state == PlayerState.ATTACK and attack_area:
		var col_disabled = true
		if attack_area.has_node("CollisionShape2D"):
			col_disabled = attack_area.get_node("CollisionShape2D").disabled
		print("Attack area status: monitoring=", attack_area.monitoring, 
		", position=", attack_area.position, ", collision disabled=", col_disabled)
	
	# Apply physics based on current state
	match current_state:
		PlayerState.IDLE, PlayerState.RUN:
			handle_movement(delta)
		PlayerState.JUMP, PlayerState.FALL:
			handle_air_movement(delta)
		PlayerState.WALL_SLIDE:
			handle_wall_slide(delta)
		PlayerState.ATTACK:
			# Allow limited movement during attacks
			if is_on_floor():
				velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
			else:
				handle_air_movement(delta, 0.5)  # Half control in air while attacking
		PlayerState.DASH:
			handle_dash(delta)
		PlayerState.HIT:
			# No movement while being hit
			if is_on_floor():
				velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
			else:
				apply_gravity(delta)
		PlayerState.DEATH:
			# No movement when dead
			if is_on_floor():
				velocity.x = 0
			else:
				apply_gravity(delta)
	
	# Handle invincibility timer
	if is_invincible:
		invincibility_timer += delta
		if invincibility_timer >= invincibility_time:
			is_invincible = false
			invincibility_timer = 0.0
			# Exit invincibility state
			modulate.a = 1.0  # Return to full opacity
	
	# Cooldown timers
	handle_cooldowns(delta)
	
	# Handle animation
	handle_animation(delta)
	
	# Move character with snap to ground
	var was_on_floor = is_on_floor()
	
	# Use snap vector to stick to ground
	var snap_vector = Vector2.DOWN * 16 if !is_jumping() and !is_dashing() else Vector2.ZERO
	move_and_slide()
	
	# Snap to floor if we're close enough (prevents floating)
	if !was_on_floor and is_on_floor() and velocity.y >= 0:
		# We just landed, adjust position firmly to the ground
		position.y = floor(position.y)
		# Play landing sound
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_sound("player_land", 0.7)
	
	# Update floor state for next frame
	was_on_floor = is_on_floor()
	
	# Force player to stop at the floor
	if is_on_floor():
		velocity.y = 0
	
	# Check if falling
	if current_state != PlayerState.DEATH and current_state != PlayerState.HIT and current_state != PlayerState.DASH and !is_attacking:
		if !is_on_floor() and velocity.y > 0 and current_state != PlayerState.WALL_SLIDE:
			current_state = PlayerState.FALL
		elif is_on_floor() and (current_state == PlayerState.FALL or current_state == PlayerState.JUMP):
			current_state = PlayerState.IDLE
			can_double_jump = true  # Reset double jump when touching ground
	
	# Check for wall slide
	check_wall_slide()
	
	# Debug
	if debug_label:
		debug_label.text = "State: " + str(current_state) + "\nVelocity: " + str(velocity) + "\nOn Floor: " + str(is_on_floor())

func handle_cooldowns(delta):
	# Handle dash cooldown
	if !can_dash:
		dash_timer -= delta
		if dash_timer <= 0:
			can_dash = true
			emit_signal("dash_ready_changed", true)
	
	# Handle wall jump cooldown
	if !can_wall_jump:
		wall_jump_cooldown_timer -= delta
		if wall_jump_cooldown_timer <= 0:
			can_wall_jump = true
	
	# Handle attack combo timeout
	if attack_combo > 0:
		attack_combo_timer -= delta
		if attack_combo_timer <= 0:
			attack_combo = 0

func handle_movement(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Only allow movement if not attacking
	if !is_attacking:
		if direction:
			velocity.x = lerp(velocity.x, direction * SPEED, ACCELERATION * delta)
			if is_on_floor():
				current_state = PlayerState.RUN
			
			# Set facing direction
			facing_right = direction > 0
		else:
			velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
			if is_on_floor():
				current_state = PlayerState.IDLE
	
		# Handle jump
		if Input.is_action_just_pressed("ui_up") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			current_state = PlayerState.JUMP
			can_double_jump = true  # Enable double jump when jumping from ground
			# Play jump sound
			if get_node_or_null("/root/AudioManager") != null:
				get_node("/root/AudioManager").play_sound("player_jump", 0.8)
	
	# Apply gravity
	apply_gravity(delta)
	
	# Handle dash
	if Input.is_action_just_pressed("ui_dash") and can_dash:
		initiate_dash()
	
	# Handle attack
	if Input.is_action_just_pressed("ui_attack") and !is_attacking:
		initiate_attack()
	
	# Handle special attack (projectile)
	if Input.is_action_just_pressed("ui_special") or Input.is_key_pressed(KEY_F):
		print("Special attack key pressed, health: ", health, "/", max_health)
		if health >= max_health:
			print("Activating special attack!")
			_on_special_attack_activated()
		else:
			print("Not at full health, cannot use special attack")
	
	# Test keys for take_hit and death
	if Input.is_action_just_pressed("ui_take_hit"):
		current_state = PlayerState.HIT
		is_attacking = false
	elif Input.is_action_just_pressed("ui_die"):
		current_state = PlayerState.DEATH
		is_attacking = false

func handle_air_movement(delta, control_factor = 1.0):
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if !is_attacking or control_factor > 0:
		if direction:
			velocity.x = lerp(velocity.x, direction * SPEED * control_factor, (ACCELERATION * 0.7) * delta)
			
			# Set facing direction
			facing_right = direction > 0
		else:
			velocity.x = lerp(velocity.x, 0.0, (FRICTION * 0.2) * delta)
	
	# Handle double jump
	if Input.is_action_just_pressed("ui_up") and !is_on_floor() and can_double_jump and current_state != PlayerState.WALL_SLIDE:
		velocity.y = JUMP_VELOCITY * DOUBLE_JUMP_FACTOR
		current_state = PlayerState.JUMP
		can_double_jump = false
		
	# Apply gravity
	apply_gravity(delta)
	
	# Handle dash in air
	if Input.is_action_just_pressed("ui_dash") and can_dash:
		initiate_dash()
	
	# Handle attack in air
	if Input.is_action_just_pressed("ui_attack") and !is_attacking:
		initiate_attack()

func handle_wall_slide(delta):
	# Slower fall while wall sliding
	velocity.y = min(velocity.y + (GRAVITY * GRAVITY_SCALE * delta), WALL_SLIDE_SPEED)
	
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Allow minimal movement along wall
	if direction:
		# Only allow movement away from the wall
		if (is_on_wall_only() and 
			((facing_right and direction < 0) or (!facing_right and direction > 0))):
			velocity.x = lerp(velocity.x, direction * SPEED * 0.5, ACCELERATION * 0.5 * delta)
	
	# Wall jump
	if Input.is_action_just_pressed("ui_up") and can_wall_jump:
		# Jump in the opposite direction of the facing direction
		velocity.x = WALL_JUMP_VELOCITY.x * (-1 if facing_right else 1)
		velocity.y = WALL_JUMP_VELOCITY.y
		current_state = PlayerState.JUMP
		can_wall_jump = false
		wall_jump_cooldown_timer = WALL_JUMP_COOLDOWN
		
		# Flip facing direction
		facing_right = !facing_right
		
	# Exit wall slide if not against wall
	if !is_on_wall_only() or is_on_floor():
		current_state = PlayerState.IDLE if is_on_floor() else PlayerState.FALL

func check_wall_slide():
	if !is_on_floor() and is_on_wall() and velocity.y > 0 and Input.get_axis("ui_left", "ui_right") != 0:
		var wall_normal = Vector2.ZERO
		
		# Check all collisions to find wall
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var normal = collision.get_normal()
			
			# Wall collision will have significant horizontal component
			if abs(normal.x) > 0.5:
				wall_normal = normal
				break
		
		if wall_normal != Vector2.ZERO:
			# Check if we're pressing toward the wall
			if (wall_normal.x > 0 and Input.is_action_pressed("ui_left")) or (wall_normal.x < 0 and Input.is_action_pressed("ui_right")):
				current_state = PlayerState.WALL_SLIDE
				facing_right = wall_normal.x > 0  # Face away from wall

func apply_gravity(delta):
	# Apply gravity with slightly increased strength
	velocity.y = min(velocity.y + (GRAVITY * GRAVITY_SCALE * delta * 1.1), TERMINAL_VELOCITY)

func initiate_dash():
	if !can_dash:
		return
		
	current_state = PlayerState.DASH
	dash_timer = DASH_COOLDOWN
	can_dash = false
	is_attacking = false
	emit_signal("dash_ready_changed", false)
	
	# Play dash sound
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_sound("player_dash", 0.8)
	
	# Dash in the facing direction or the input direction if any
	var input_direction = Input.get_axis("ui_left", "ui_right")
	if input_direction != 0:
		dash_direction = Vector2(input_direction, 0).normalized()
		facing_right = input_direction > 0
	else:
		dash_direction = Vector2(1 if facing_right else -1, 0)
	
	# Spawn dash effect
	spawn_dash_effect()
	
	# Temporary invincibility during dash
	is_invincible = true
	invincibility_timer = 0
	modulate.a = 0.7

func spawn_dash_effect():
	# Try to load the dash effect scene if it wasn't loaded before
	if dash_effect_scene == null:
		if ResourceLoader.exists("res://scenes/effects/DashEffect.tscn"):
			dash_effect_scene = load("res://scenes/effects/DashEffect.tscn")
		elif ResourceLoader.exists("res://scenes/effects/SlashEffect.tscn"):
			dash_effect_scene = load("res://scenes/effects/SlashEffect.tscn")
		elif ResourceLoader.exists("res://scenes/Effects/DashEffect.tscn"):
			dash_effect_scene = load("res://scenes/Effects/DashEffect.tscn")
		elif ResourceLoader.exists("res://scenes/Effects/SlashEffect.tscn"):
			dash_effect_scene = load("res://scenes/Effects/SlashEffect.tscn")

	if dash_effect_scene and is_inside_tree():
		var effect = dash_effect_scene.instantiate()
		get_tree().current_scene.add_child(effect)  # Use current_scene instead of get_parent()
		effect.global_position = global_position
		effect.scale.x = -1 if !facing_right else 1
		
		# Default setup for the effect if needed
		if effect.has_method("play"):
			effect.play()
		if effect.has_method("start"):
			effect.start()
		
		# Trail effect - only create timer if we're in the tree
		if is_inside_tree():
			var trail_timer = get_tree().create_timer(DASH_DURATION / 3)
			trail_timer.timeout.connect(_on_dash_trail_timer_timeout)

func _on_dash_trail_timer_timeout():
	if current_state == PlayerState.DASH:
		spawn_dash_effect()

func handle_dash(delta):
	# Apply dash movement
	velocity = dash_direction * DASH_SPEED
	
	# End dash after duration
	dash_timer -= delta
	if dash_timer <= DASH_COOLDOWN - DASH_DURATION:
		if is_on_floor():
			current_state = PlayerState.IDLE
		else:
			current_state = PlayerState.FALL
		
		# End dash invincibility
		is_invincible = false
		modulate.a = 1.0

func initiate_attack():
	current_state = PlayerState.ATTACK
	is_attacking = true
	
	# Play attack sound
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_sound("player_attack", 0.8)
	
	# Handle attack combo
	if attack_combo > 0 and attack_combo_timer > 0:
		attack_combo = (attack_combo % 2) + 1  # Toggle between 1 and 2
	else:
		attack_combo = 1
	
	attack_combo_timer = attack_combo_timeout
	
	# Debug output
	print("Player attacking! Combo:", attack_combo)
	
	# Ensure attack area exists and is properly configured
	if !attack_area or !is_instance_valid(attack_area):
		print("Creating new attack area")
		attack_area = Area2D.new()
		attack_area.name = "AttackArea"
		var col_shape = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(60, 80)  # Larger attack area for better detection
		col_shape.shape = shape
		attack_area.add_child(col_shape)
		add_child(attack_area)
		
		# Connect signal
		attack_area.body_entered.connect(_on_attack_area_body_entered)
	
	# Configure attack area
	attack_area.collision_layer = 0  # No collision layer needed
	attack_area.collision_mask = 4  # Only detect enemies (layer 3)
	
	# Update attack area position and enable it
	update_attack_area()
	
	# Actively check for enemies in the area immediately
	check_for_enemies_in_attack_area()
	
	# Spawn hit effect after small delay
	if is_inside_tree():
		var effect_timer = get_tree().create_timer(0.1)
		effect_timer.timeout.connect(_on_attack_effect_timer_timeout)

func _on_attack_effect_timer_timeout():
	# Spawn hit effect - check if we're still in the tree
	if hit_effect_scene and is_inside_tree():
		var hit_effect = hit_effect_scene.instantiate()
		get_tree().current_scene.add_child(hit_effect)  # Use current_scene for more reliability
		
		# Position in front of player based on attack range and facing direction
		var effect_position = global_position + Vector2(50 if facing_right else -50, 0)
		
		# If the attack area exists, use its position instead
		if attack_area:
			effect_position = attack_area.global_position
		
		hit_effect.global_position = effect_position
		
		# Setup the effect properly
		if hit_effect.has_node("Sprite2D"):
			hit_effect.get_node("Sprite2D").flip_h = !facing_right
		
		# If the effect has a timer, extend it slightly
		if hit_effect.has_method("set_lifetime"):
			hit_effect.set_lifetime(0.5)  # Half second effect
		elif hit_effect.has_node("Timer"):
			var timer = hit_effect.get_node("Timer")
			timer.wait_time = 0.5  # Half second effect
		
		# If the effect has play or start methods, call them
		if hit_effect.has_method("play"):
			hit_effect.play()
		if hit_effect.has_method("start"):
			hit_effect.start()

func handle_animation(delta):
	# Ensure sprite exists before proceeding
	if !sprite or !is_inside_tree():
		return
		
	# Get the animation based on the current state
	var new_animation = ""
	var offset = Vector2.ZERO
	
	match current_state:
		PlayerState.IDLE:
			new_animation = "idle"
		PlayerState.RUN:
			new_animation = "run"
		PlayerState.JUMP:
			new_animation = "jump"
		PlayerState.FALL, PlayerState.WALL_SLIDE:
			if current_state == PlayerState.WALL_SLIDE:
				new_animation = "wall_slide"
			else:
				new_animation = "fall"
		PlayerState.ATTACK:
			new_animation = "attack" + str(attack_combo)
		PlayerState.DASH:
			new_animation = "run"  # Using run animation for dash
		PlayerState.HIT:
			new_animation = "take_hit"
		PlayerState.DEATH:
			new_animation = "death"
	
	# Change animation if it's different
	if new_animation != current_animation:
		current_animation = new_animation
		current_frame = 0
		animation_timer = 0
		
		# Load the appropriate texture based on animation
		var texture_path = ""
		match current_animation:
			"idle":
				texture_path = "res://Assets/Sprites/Martial Hero 2/Sprites/Idle.png"
				sprite.hframes = frame_counts["idle"]
			"run":
				texture_path = "res://Assets/Sprites/Martial Hero 2/Sprites/Run.png"
				sprite.hframes = frame_counts["run"]
			"jump":
				texture_path = "res://Assets/Sprites/Martial Hero 2/Sprites/Jump.png"
				sprite.hframes = frame_counts["jump"]
			"fall":
				texture_path = "res://Assets/Sprites/Martial Hero 2/Sprites/Fall.png"
				sprite.hframes = frame_counts["fall"]
			"attack1":
				texture_path = "res://Assets/Sprites/Martial Hero 2/Sprites/Attack1.png"
				sprite.hframes = frame_counts["attack1"]
			"attack2":
				texture_path = "res://Assets/Sprites/Martial Hero 2/Sprites/Attack2.png"
				sprite.hframes = frame_counts["attack2"]
			"take_hit":
				texture_path = "res://Assets/Sprites/Martial Hero 2/Sprites/Take Hit.png"
				sprite.hframes = frame_counts["take_hit"]
			"death":
				texture_path = "res://Assets/Sprites/Martial Hero 2/Sprites/Death.png"
				sprite.hframes = frame_counts["death"]
			"wall_slide":
				texture_path = "res://Assets/Sprites/Martial Hero 2/Sprites/Fall.png"  # Using fall for wall slide
				sprite.hframes = frame_counts["wall_slide"]
		
		# Safely load texture
		if ResourceLoader.exists(texture_path):
			sprite.texture = load(texture_path)
		else:
			print("ERROR: Could not load texture: ", texture_path)
		
		# Set animation properties
		if current_animation in frame_counts:
			frame_count = frame_counts[current_animation]
		else:
			frame_count = 4  # Default if not specified
	
	# Get the offset for the current animation
	if current_animation in animation_offsets:
		offset = animation_offsets[current_animation]
		# Flip offset if facing left
		if !facing_right:
			offset.x = -offset.x
	
	# Update sprite offset
	sprite.position.x = offset.x
	
	# Flip sprite based on facing direction
	sprite.flip_h = !facing_right
	
	# Update animation frame
	animation_timer += delta
	var frame_duration = 1.0
	if current_animation in animation_speeds:
		frame_duration = 1.0 / animation_speeds[current_animation]
	else:
		frame_duration = 1.0 / 10.0
	
	if animation_timer >= frame_duration:
		animation_timer -= frame_duration
		current_frame = (current_frame + 1) % frame_count
		sprite.frame = current_frame
		
		# Check for animation end
		if current_frame == 0:
			on_animation_finished()

func on_animation_finished():
	match current_state:
		PlayerState.ATTACK:
			# When attack animation finishes, return to idle or fall
			if is_on_floor():
				current_state = PlayerState.IDLE
			else:
				current_state = PlayerState.FALL
			is_attacking = false
			
			# Disable attack area with a small delay to ensure collisions are processed
			if attack_area and is_inside_tree():
				var disable_timer = get_tree().create_timer(0.1)
				disable_timer.timeout.connect(_on_disable_attack_area)
		PlayerState.HIT:
			# When hit animation finishes, return to idle or fall
			if is_on_floor():
				current_state = PlayerState.IDLE
			else:
				current_state = PlayerState.FALL
		PlayerState.DEATH:
			# Player died, reload level or game over screen
			if is_inside_tree() and has_node("/root/GameManager") and get_node("/root/GameManager").has_method("restart_level"):
				get_node("/root/GameManager").restart_level()
			else:
				# Fallback if GameManager doesn't exist
				if is_inside_tree():
					get_tree().reload_current_scene()

func heal(amount):
	health = min(health + amount, max_health)
	
	# Update GameManager health
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		game_manager.update_player_health(health)
	
	emit_signal("health_changed", health)
	
	# Special ready if at full health
	if health >= max_health:
		emit_signal("special_ready_changed", true)
	else:
		emit_signal("special_ready_changed", false)

func is_dash_ready() -> bool:
	return can_dash

func take_damage(damage, attacker_position = null):
	if is_invincible or is_dead:
		return
		
	health -= damage
	
	# Play hit sound
	if get_node_or_null("/root/AudioManager") != null:
		get_node("/root/AudioManager").play_sound("player_hit", 0.8)
	
	# Update GameManager health
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		game_manager.update_player_health(health)
		
	emit_signal("health_changed", health)
	
	# Check if dash or special is ready
	if dash_timer <= 0:
		emit_signal("dash_ready_changed", true)
	if health >= max_health:
		emit_signal("special_ready_changed", true)
	else:
		emit_signal("special_ready_changed", false)
	
	# Apply enhanced knockback
	if attacker_position:
		var knockback_direction = global_position - attacker_position
		knockback_direction = knockback_direction.normalized()
		
		# Enhanced horizontal knockback
		velocity.x = knockback_direction.x * 400.0
		
		# Add vertical component for more dramatic effect
		velocity.y = min(velocity.y, -200.0)
		
		# Apply a brief slowdown for more impact feel
		if is_inside_tree():
			Engine.time_scale = 0.7  # Slow down game briefly
			var reset_timer = get_tree().create_timer(0.15 * Engine.time_scale)  # Accounting for time scale
			reset_timer.timeout.connect(_on_time_scale_reset)
	
	# Visual feedback - flash white and transparent
	modulate = Color(1.5, 1.5, 1.5, 0.7)  # Bright flash
	is_invincible = true
	invincibility_timer = 0.0
	
	# Reset modulate with a series of flashes during invincibility
	if is_inside_tree():
		var flash_count = 5
		var flash_duration = invincibility_time / flash_count
		
		for i in range(flash_count):
			var flash_timer = get_tree().create_timer((i+1) * flash_duration)
			flash_timer.timeout.connect(_on_invincibility_flash)
		
		# Final reset at the end of invincibility
		var final_timer = get_tree().create_timer(invincibility_time)
		final_timer.timeout.connect(_on_invincibility_end)
	
	# Play hit animation
	current_state = PlayerState.HIT
	is_attacking = false
	
	if health <= 0:
		die()

func die():
	if is_dead:
		return
		
	is_dead = true
	current_state = PlayerState.DEATH
	is_attacking = false
	
	# Play death sound
	if get_node_or_null("/root/AudioManager") != null:
		get_node("/root/AudioManager").play_sound("player_death", 1.0)
	
	# Player will be handled after death animation finishes

func fire_projectile():
	print("Attempting to fire projectile...")
	if projectile_scene == null:
		# Try to load the projectile scene again
		if ResourceLoader.exists("res://scenes/Projectile.tscn"):
			projectile_scene = load("res://scenes/Projectile.tscn")
		elif ResourceLoader.exists("res://scenes/enemies/Projectile.tscn"):
			projectile_scene = load("res://scenes/enemies/Projectile.tscn")
		elif ResourceLoader.exists("res://scenes/Effects/Projectile.tscn"):
			projectile_scene = load("res://scenes/Effects/Projectile.tscn")
		elif ResourceLoader.exists("res://scenes/effects/Projectile.tscn"):
			projectile_scene = load("res://scenes/effects/Projectile.tscn")
		elif ResourceLoader.exists("res://scenes/effects/SlashEffect.tscn"):
			# Use slash effect if no projectile is available
			projectile_scene = load("res://scenes/effects/SlashEffect.tscn")
	
	# If still no projectile scene, try to create one dynamically
	if projectile_scene == null:
		print("Creating dynamic projectile...")
		var scene = PackedScene.new()
		var projectile_node = Projectile.new()
		scene.pack(projectile_node)
		projectile_scene = scene
	
	if not is_inside_tree():
		print("ERROR: Node is not in tree!")
		return
		
	# Create a spawn point if one doesn't exist
	if projectile_spawn == null:
		print("WARNING: projectile_spawn node is null! Creating temporary spawn point.")
		var spawn_position = global_position
		spawn_position.x += 40 * (1 if facing_right else -1)  # Offset in front of player
		
		# Create the projectile at this position instead
		var projectile = projectile_scene.instantiate()
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = spawn_position
		projectile.direction = Vector2(1 if facing_right else -1, 0)
		projectile.speed = 800  # Even faster projectile
		projectile.damage = 240  # 3x the strongest slash attack (80*3)
		projectile.source_entity = self  # Set the source entity to player
		print("Projectile fired in direction: ", projectile.direction)
	else:
		# Normal case with projectile_spawn node
		print("Creating projectile instance...")
		var projectile = projectile_scene.instantiate()
		get_tree().current_scene.add_child(projectile)  # Use current_scene instead of get_parent()
		projectile.global_position = projectile_spawn.global_position
		projectile.direction = Vector2(1 if facing_right else -1, 0)
		projectile.speed = 800  # Even faster projectile
		projectile.damage = 240  # 3x the strongest slash attack (80*3)
		projectile.source_entity = self  # Set the source entity to player
		print("Projectile fired in direction: ", projectile.direction)
	
	# Visual feedback
	modulate = Color(1.2, 1.2, 2.0)  # Blue tint
	if is_inside_tree():
		var tint_timer = get_tree().create_timer(0.2)
		tint_timer.timeout.connect(_on_projectile_tint_end)

func _on_special_attack_activated():
	print("Special attack activated!")
	emit_signal("special_ready_changed", false)
	health -= 5  # Use a small amount of health to prevent spamming
	
	# Play projectile sound
	if get_node_or_null("/root/AudioManager") != null:
		get_node("/root/AudioManager").play_sound("player_projectile", 0.9)
	
	# Update GameManager health
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		game_manager.update_player_health(health)
		
	emit_signal("health_changed", health)
	fire_projectile()

func _on_attack_area_body_entered(body):
	print("Attack area hit something:", body.name)
	
	# Check if it's an enemy
	if body.is_in_group("enemy"):
		print("Hit an enemy: ", body.name)
		
		if body.has_method("take_damage"):
			# Calculate attack damage based on combo
			var attack_damage = 60 if attack_combo == 1 else 80  # Regular melee attack damage (projectiles do 3x this amount)
			print("Applying ", attack_damage, " damage to enemy")
			
			# Apply damage to enemy with knockback
			var knockback_dir = (body.global_position - global_position).normalized()
			var knockback_strength = 250 if attack_combo == 1 else 300  # Second attack has stronger knockback
			body.take_damage(attack_damage, knockback_dir, knockback_strength)
			
			# Apply knockback to player (recoil)
			var recoil_dir = (global_position - body.global_position).normalized()
			velocity += recoil_dir * 100
			
			# Add screen shake for impact feedback
			if is_inside_tree():
				# Add hit pause for more impact
				Engine.time_scale = 0.05  # Almost freeze the game momentarily
				var reset_timer = get_tree().create_timer(0.03 * Engine.time_scale)  # Short duration
				reset_timer.timeout.connect(_on_time_scale_reset)
				
				# Add visual impact flash
				modulate = Color(1.2, 1.2, 1.2)  # Bright flash
				var color_timer = get_tree().create_timer(0.1)
				color_timer.timeout.connect(_on_attack_impact_flash_end)
		else:
			print("ERROR: Enemy does not have take_damage method!")

# Function to actively check for enemies in the attack area
func check_for_enemies_in_attack_area():
	if !attack_area or !is_instance_valid(attack_area):
		return
		
	print("Checking for enemies in attack area...")
	
	# Make sure attack area is enabled
	if attack_area.has_node("CollisionShape2D"):
		attack_area.get_node("CollisionShape2D").disabled = false
	attack_area.monitoring = true
	attack_area.monitorable = true
	
	# Get all bodies in the attack area
	var bodies = attack_area.get_overlapping_bodies()
	print("Found ", bodies.size(), " bodies in attack area")
	
	# Process each body
	for body in bodies:
		print("Checking body: ", body.name)
		if body.is_in_group("enemy"):
			print("Found enemy in attack area: ", body.name)
			_on_attack_area_body_entered(body)
	
	# Also use physics raycasting for additional detection
	var space_state = get_world_2d().direct_space_state
	var attack_direction = 1 if facing_right else -1
	var ray_start = global_position
	var ray_end = global_position + Vector2(attack_direction * 80, 0)  # 80 pixels in facing direction
	
	# Create physics ray query
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end, 4)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	# Perform raycast
	var result = space_state.intersect_ray(query)
	if result and result.collider and result.collider.is_in_group("enemy"):
		print("Raycast hit enemy: ", result.collider.name)
		_on_attack_area_body_entered(result.collider)

# Function to check if player is jumping
func is_jumping():
	return current_state == PlayerState.JUMP

# Function to check if player is dashing
func is_dashing():
	return current_state == PlayerState.DASH

func update_attack_area():
	if attack_area and attack_area.has_node("CollisionShape2D"):
		# Position the attack area in front of the player based on facing direction
		var attack_shape = attack_area.get_node("CollisionShape2D")
		
		# Make sure shape has size property (RectangleShape2D)
		if attack_shape.shape and attack_shape.shape is RectangleShape2D:
			# Increase size of attack area
			attack_shape.shape.size = Vector2(80, 100)  # Larger attack area
			
		# Increase offset to reach farther
		var offset_x = 40  # Increased from 30
		attack_area.position.x = offset_x if facing_right else -offset_x
		attack_shape.disabled = false
		attack_area.monitoring = true
		attack_area.monitorable = true
		print("Attack area enabled:", attack_area.monitoring)

func _on_disable_attack_area():
	print("Disabling attack area after delay")
	if attack_area and is_instance_valid(attack_area):
		attack_area.monitoring = false
		attack_area.monitorable = false
		if attack_area.has_node("CollisionShape2D"):
			var col_shape = attack_area.get_node("CollisionShape2D")
			col_shape.set_deferred("disabled", true)

func _on_time_scale_reset():
	Engine.time_scale = 1.0

func _on_invincibility_flash():
	modulate.a = 1.0 if modulate.a < 1.0 else 0.5

func _on_invincibility_end():
	modulate = Color(1, 1, 1, 1)

func _on_projectile_tint_end():
	modulate = Color(1, 1, 1)

func _on_attack_impact_flash_end():
	modulate = Color(1, 1, 1)
