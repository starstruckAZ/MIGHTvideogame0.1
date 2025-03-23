extends CharacterBody2D

# Player movement variables
@export var speed = 300.0
@export var jump_velocity = -400.0
@export var gravity = 980

# Dash variables
@export var dash_speed = 800.0
@export var dash_duration = 0.2
@export var dash_cooldown = 0.6
var can_dash = true
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = Vector2.RIGHT

# Health system variables
@export var max_health = 100
var current_health = max_health
var invincible = false
var invincibility_duration = 0.6
var invincibility_timer = 0.0
var health_regeneration = false
signal health_changed(new_health, max_health)
signal player_died

# Animation variables
var frame_timer = 0.0
var frame_duration = 0.1
var current_frame = 0
var frame_count = 4  # Default frame count for idle animation

# Animation textures
var texture_idle: Texture
var texture_run: Texture
var texture_jump: Texture
var texture_fall: Texture
var texture_attack1: Texture
var texture_attack2: Texture
var texture_take_hit: Texture
var texture_death: Texture

# Animation frame counts
var frame_counts = {
	"idle": 4,
	"run": 8,
	"jump": 2,
	"fall": 2,
	"attack1": 4,
	"attack2": 4,
	"take_hit": 3,
	"death": 7
}

# Animation speeds (frames per second)
var animation_speeds = {
	"idle": 8.0,
	"run": 12.0,
	"jump": 10.0,
	"fall": 10.0,
	"attack1": 15.0,
	"attack2": 15.0,
	"take_hit": 10.0,
	"death": 10.0
}

# Animation offsets (for special animations like attacks)
var animation_offsets = {
	"idle": Vector2(-0.125, 0),
	"run": Vector2(-0.125, 0),
	"jump": Vector2(-0.125, 0),
	"fall": Vector2(-0.125, 0),
	"attack1": Vector2(10, 0),  # Offset to the right to show full sword swing
	"attack2": Vector2(12, 0),  # Slightly larger offset for second attack
	"take_hit": Vector2(-0.125, 0),
	"death": Vector2(-0.125, 0)
}

# Combat variables
var is_attacking = false
var attack_cooldown = 0.0
var attack_cooldown_time = 0.4
var attack_combo_count = 0
var last_attack_time = 0.0
var combo_timeout = 0.8  # Time window for combos

# Projectile variables
var projectile_scene = preload("res://scenes/effects/Projectile.tscn")
@export var projectile_cost = 20  # Health cost to fire projectile

# Movement variables
var can_double_jump = true
var can_wall_jump = true
var wall_jump_cooldown = 0.0
var wall_jump_cooldown_time = 0.2
var wall_slide_speed = 100.0
var wall_jump_velocity = Vector2(400, -400)  # X and Y velocity for wall jump

# State variables
var is_hit = false
var is_dead = false
var is_wall_sliding = false

# Animation states
enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK_1,
	ATTACK_2,
	TAKE_HIT,
	DEATH,
	WALL_SLIDE,
	DASH
}

var current_state = PlayerState.IDLE

# Visual effects nodes
var dust_scene = preload("res://scenes/effects/DustEffect.tscn")
var slash_scene = preload("res://scenes/effects/SlashEffect.tscn")

# Add these signals near the top of the file with other signals
signal dash_ready_changed(is_ready)
signal special_ready_changed(is_ready)

func _ready():
	# Load all the textures
	texture_idle = load("res://Assets/Sprites/Martial Hero 2/Sprites/Idle.png")
	texture_run = load("res://Assets/Sprites/Martial Hero 2/Sprites/Run.png")
	texture_jump = load("res://Assets/Sprites/Martial Hero 2/Sprites/Jump.png")
	texture_fall = load("res://Assets/Sprites/Martial Hero 2/Sprites/Fall.png")
	texture_attack1 = load("res://Assets/Sprites/Martial Hero 2/Sprites/Attack1.png")
	texture_attack2 = load("res://Assets/Sprites/Martial Hero 2/Sprites/Attack2.png")
	texture_take_hit = load("res://Assets/Sprites/Martial Hero 2/Sprites/Take hit.png")
	texture_death = load("res://Assets/Sprites/Martial Hero 2/Sprites/Death.png")
	
	# Initialize with idle animation
	$Sprite2D.texture = texture_idle
	$Sprite2D.hframes = frame_counts["idle"]
	$Sprite2D.frame = 0
	$Sprite2D.offset = animation_offsets["idle"]
	frame_count = frame_counts["idle"]
	frame_duration = 1.0 / animation_speeds["idle"]
	
	# Initialize health
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)
	emit_signal("special_ready_changed", true)

func _physics_process(delta):
	# Simple animation
	frame_timer += delta
	if frame_timer >= frame_duration:
		frame_timer = 0
		current_frame = (current_frame + 1) % frame_count
		$Sprite2D.frame = current_frame
	
	# Dash cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			can_dash = true
			emit_signal("dash_ready_changed", true)
	
	# Handle invincibility
	if invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			invincible = false
			$Sprite2D.modulate = Color(1, 1, 1, 1)  # Reset to normal color
		else:
			# Flash the sprite while invincible
			var alpha = 0.4 if fmod(invincibility_timer, 0.2) > 0.1 else 1.0
			$Sprite2D.modulate = Color(1, 1, 1, alpha)
	
	# Handle dash duration
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			velocity = Vector2.ZERO  # Stop after dash
		else:
			velocity = dash_direction * dash_speed
			# Create dash effect
			_spawn_dash_particles()
			move_and_slide()
			return
	
	# Wall jump cooldown
	if wall_jump_cooldown > 0:
		wall_jump_cooldown -= delta
	
	# Test inputs for hit and death animations
	if Input.is_action_just_pressed("take_hit") and !is_hit and !is_dead and !is_attacking and !is_dashing:
		take_damage(10)  # Test damage amount
		return
		
	if Input.is_action_just_pressed("death") and !is_dead and !is_hit and !is_attacking and !is_dashing:
		is_dead = true
		_change_state(PlayerState.DEATH)
		return
	
	# Don't process movement during hit or death animations
	if is_hit or is_dead:
		move_and_slide()
		return
	
	# Handle attack cooldown
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	# Reset combo if timeout
	if Time.get_ticks_msec() - last_attack_time > combo_timeout * 1000:
		attack_combo_count = 0
	
	# Handle dash
	if Input.is_action_just_pressed("dash") and can_dash and !is_attacking and !is_hit:
		_start_dash()
		return
	
	# Handle attacks
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0 and !is_dashing:
		is_attacking = true
		attack_cooldown = attack_cooldown_time
		last_attack_time = Time.get_ticks_msec()
		
		# Determine which attack to use
		attack_combo_count += 1
		if attack_combo_count >= 3 or (attack_combo_count == 2 and randf() > 0.5):
			# Use second attack animation after third hit or sometimes on second hit
			_change_state(PlayerState.ATTACK_2)
			attack_combo_count = 0  # Reset combo after special attack
		else:
			_change_state(PlayerState.ATTACK_1)
		
		# Check if at full health to fire projectile
		if current_health == max_health:
			_fire_projectile()
		
		# Spawn attack visual effect
		_spawn_attack_effect()
	
	# Don't process movement during attacks
	if is_attacking:
		# Allow continued horizontal movement during attacks
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * speed * 0.7  # Slightly reduced speed during attack
			$Sprite2D.flip_h = direction < 0
		
		move_and_slide()
		return
	
	# Get the input direction
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Check for wall sliding
	is_wall_sliding = false
	if is_on_wall() and !is_on_floor() and direction != 0:
		is_wall_sliding = true
		velocity.y = min(velocity.y, wall_slide_speed)
		if wall_jump_cooldown <= 0:
			can_wall_jump = true
		
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
		# Update animation state based on vertical movement
		if is_wall_sliding:
			_change_state(PlayerState.WALL_SLIDE)
		elif velocity.y > 0:
			_change_state(PlayerState.FALL)
		else:
			_change_state(PlayerState.JUMP)
	else:
		# Reset double jump and dash when on floor
		can_double_jump = true
		if dash_cooldown_timer <= 0:
			can_dash = true
	
	# Handle wall jump
	if is_wall_sliding and Input.is_action_just_pressed("ui_accept") and can_wall_jump:
		velocity.y = wall_jump_velocity.y
		# Jump away from wall
		velocity.x = wall_jump_velocity.x * -direction
		can_wall_jump = false
		wall_jump_cooldown = wall_jump_cooldown_time
		_change_state(PlayerState.JUMP)
		_spawn_jump_particles()
	# Handle regular jump and double jump
	elif Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = jump_velocity
			_change_state(PlayerState.JUMP)
			_spawn_jump_particles()
		elif can_double_jump and !is_wall_sliding:
			velocity.y = jump_velocity * 0.8  # Slightly weaker double jump
			can_double_jump = false
			_change_state(PlayerState.JUMP)
			_spawn_jump_particles()
			
	# Handle horizontal movement
	if direction and !is_wall_sliding and !is_dashing:
		velocity.x = direction * speed
		# Flip sprite based on direction
		$Sprite2D.flip_h = direction < 0
		if is_on_floor():
			_change_state(PlayerState.RUN)
			# Spawn run dust occasionally while running on ground
			if randf() < 0.05:  # 5% chance per frame
				_spawn_run_particles()
	elif !is_wall_sliding and !is_dashing:
		velocity.x = move_toward(velocity.x, 0, speed)
		if is_on_floor():
			_change_state(PlayerState.IDLE)
	
	# Apply movements
	move_and_slide()

# Start a dash in the direction the player is facing
func _start_dash():
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	
	# Determine dash direction
	if $Sprite2D.flip_h:
		dash_direction = Vector2.LEFT
	else:
		dash_direction = Vector2.RIGHT
	
	# Become invincible during dash
	_set_invincible(dash_duration)
	
	# Create trail effect
	_spawn_dash_particles()
	emit_signal("dash_ready_changed", false)

# Apply damage to the player
func take_damage(amount):
	if invincible or is_dead or is_dashing:
		return
		
	current_health -= amount
	emit_signal("health_changed", current_health, max_health)
	
	if current_health <= 0:
		current_health = 0
		is_dead = true
		_change_state(PlayerState.DEATH)
		emit_signal("player_died")
	else:
		is_hit = true
		_change_state(PlayerState.TAKE_HIT)
		_set_invincible(invincibility_duration)
		if current_health == max_health:
			emit_signal("special_ready_changed", false)

# Set player invincible for a duration
func _set_invincible(duration):
	invincible = true
	invincibility_timer = duration

# Heal the player
func heal(amount):
	current_health = min(current_health + amount, max_health)
	emit_signal("health_changed", current_health, max_health)
	if current_health == max_health:
		emit_signal("special_ready_changed", true)

# Set sprite for animation state
func _set_animation(anim_name: String, texture: Texture):
	if $Sprite2D.texture != texture:
		$Sprite2D.texture = texture
		$Sprite2D.hframes = frame_counts[anim_name]
	
	# Apply animation offset
	$Sprite2D.offset = animation_offsets[anim_name]
	if $Sprite2D.flip_h and anim_name in ["attack1", "attack2"]:
		# Mirror the offset when facing left during attacks
		$Sprite2D.offset.x = -$Sprite2D.offset.x
	
	frame_count = frame_counts[anim_name]
	frame_duration = 1.0 / animation_speeds[anim_name]
	current_frame = 0
	$Sprite2D.frame = 0

# Change player state and update animation
func _change_state(new_state):
	if new_state == current_state:
		return
	
	# Don't interrupt attack animations
	if is_attacking and (current_state == PlayerState.ATTACK_1 or current_state == PlayerState.ATTACK_2) and (new_state != PlayerState.ATTACK_1 and new_state != PlayerState.ATTACK_2):
		return
		
	# Don't interrupt hit or death animations
	if is_hit and current_state == PlayerState.TAKE_HIT:
		return
		
	if is_dead and current_state == PlayerState.DEATH:
		return
	
	current_state = new_state
	
	# Reset animation timer when state changes
	frame_timer = 0
	
	# Set the appropriate animation for each state
	match current_state:
		PlayerState.IDLE:
			_set_animation("idle", texture_idle)
		PlayerState.RUN:
			_set_animation("run", texture_run)
		PlayerState.JUMP:
			_set_animation("jump", texture_jump)
		PlayerState.FALL:
			_set_animation("fall", texture_fall)
		PlayerState.WALL_SLIDE:
			_set_animation("fall", texture_fall)  # Reuse fall animation for wall slide
		PlayerState.DASH:
			# Reuse run animation for dash
			_set_animation("run", texture_run)
		PlayerState.ATTACK_1:
			_set_animation("attack1", texture_attack1)
			# Reset attack state after animation completes
			var attack_duration = frame_counts["attack1"] * frame_duration
			await get_tree().create_timer(attack_duration).timeout
			is_attacking = false
			if is_on_floor():
				_change_state(PlayerState.IDLE)
			else:
				if velocity.y > 0:
					_change_state(PlayerState.FALL)
				else:
					_change_state(PlayerState.JUMP)
		PlayerState.ATTACK_2:
			_set_animation("attack2", texture_attack2)
			# Reset attack state after animation completes
			var attack_duration = frame_counts["attack2"] * frame_duration
			await get_tree().create_timer(attack_duration).timeout
			is_attacking = false
			if is_on_floor():
				_change_state(PlayerState.IDLE)
		PlayerState.TAKE_HIT:
			_set_animation("take_hit", texture_take_hit)
			# Return to idle after hit animation completes
			var hit_duration = frame_counts["take_hit"] * frame_duration
			await get_tree().create_timer(hit_duration).timeout
			is_hit = false
			if is_on_floor():
				_change_state(PlayerState.IDLE)
		PlayerState.DEATH:
			_set_animation("death", texture_death)
			# Return to idle after death animation completes
			var death_duration = frame_counts["death"] * frame_duration
			await get_tree().create_timer(death_duration).timeout
			is_dead = false
			_change_state(PlayerState.IDLE)

# Visual effects functions
func _spawn_jump_particles():
	var particle = dust_scene.instantiate()
	get_parent().add_child(particle)
	particle.global_position = global_position + Vector2(0, 20)  # Position at feet
	particle.emitting = true

func _spawn_run_particles():
	var particle = dust_scene.instantiate()
	get_parent().add_child(particle)
	particle.global_position = global_position + Vector2(0, 20)  # Position at feet
	particle.scale = Vector2(0.7, 0.7)  # Smaller dust for running
	particle.emitting = true

func _spawn_dash_particles():
	var particle = dust_scene.instantiate()
	get_parent().add_child(particle)
	particle.global_position = global_position
	particle.scale = Vector2(1.5, 1.0)  # Wider effect for dash
	particle.emitting = true

func _spawn_attack_effect():
	var slash = slash_scene.instantiate()
	get_parent().add_child(slash)
	
	# Position slash in front of player
	var offset = 30
	if $Sprite2D.flip_h:
		slash.scale.x = -1  # Flip the effect
		offset = -offset
	
	slash.global_position = global_position + Vector2(offset, 0)
	slash.play("slash")  # Assuming the animation name is "slash"

# Function to fire a projectile
func _fire_projectile():
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	
	# Position and direction
	var spawn_offset = 30
	if $Sprite2D.flip_h:
		projectile.direction = Vector2.LEFT
		spawn_offset = -spawn_offset
	else:
		projectile.direction = Vector2.RIGHT
	
	projectile.position = global_position + Vector2(spawn_offset, -10)  # Slightly above the player
	projectile.rotation = projectile.direction.angle()
	
	# Visual and audio feedback
	_set_invincible(0.2)  # Brief invincibility flash
	
	# Optional: reduce health slightly as energy cost
	# current_health -= projectile_cost
	# emit_signal("health_changed", current_health, max_health)

# Add this function to check if dash is ready
func is_dash_ready() -> bool:
	return can_dash
