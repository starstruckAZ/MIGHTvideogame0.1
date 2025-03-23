extends Area2D

class_name Projectile

# NOTE: Enemies should have 8x their normal health to balance the game
# This file contains the projectile behavior and damage calculation

var direction := Vector2.RIGHT
var speed := 200.0
var damage := 10
var lifetime := 5.0  # Seconds before auto-destroying
var source_entity = null  # Store reference to the entity that shot this projectile

# Trail effect properties
var trail_enabled = true
var trail_length = 5
var trail_points = []
var trail_colors = []

func _ready():
	# Connect signal for body entered if not already connected
	if !body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	# Make sure we have a collision shape
	if !has_node("CollisionShape2D") and !has_node("CollisionPolygon2D"):
		var collision = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 5  # Small projectile hitbox
		collision.shape = shape
		add_child(collision)
		
	# Make sure we have a sprite
	if !has_node("Sprite2D"):
		var sprite = Sprite2D.new()
		# Try to load a texture
		if ResourceLoader.exists("res://Assets/Sprites/Martial Hero 2/Sprites/Fireball.png"):
			sprite.texture = load("res://Assets/Sprites/Martial Hero 2/Sprites/Fireball.png")
		elif ResourceLoader.exists("res://Assets/Projectile.png"):
			sprite.texture = load("res://Assets/Projectile.png")
		else:
			# Create a default colored shape
			var texture = GradientTexture2D.new()
			var gradient = Gradient.new()
			gradient.add_point(0, Color(1, 0.5, 0, 1))  # Orange
			gradient.add_point(1, Color(1, 0, 0, 1))    # Red
			texture.gradient = gradient
			texture.width = 16
			texture.height = 16
			texture.fill_to = Vector2(1, 1)
			texture.fill_from = Vector2(0, 0)
			texture.fill = 1  # Radial
			sprite.texture = texture
			
		add_child(sprite)
		
	# Set collision layers/masks
	collision_layer = 8  # Layer 4 (assumed projectile layer)
	if source_entity and source_entity.is_in_group("player"):
		collision_mask = 4  # Enemy layer only (removing world layer)
	else:
		collision_mask = 2  # Player layer only (removing world layer)
	
	# Start lifetime timer
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	timer.start()
	
	# Initialize trail
	for i in range(trail_length):
		trail_points.append(position)
		trail_colors.append(Color(1, 0.5, 0, 0.8 - (i * 0.15)))  # Fade out

func _physics_process(delta):
	# Move in the specified direction
	position += direction * speed * delta
	
	# Update trail
	if trail_enabled:
		trail_points.push_front(global_position)
		if trail_points.size() > trail_length:
			trail_points.pop_back()

func _draw():
	# Draw trail
	if trail_enabled and trail_points.size() > 1:
		for i in range(trail_points.size() - 1):
			if i < trail_colors.size():
				var start_pos = to_local(trail_points[i])
				var end_pos = to_local(trail_points[i + 1])
				var width = 8.0 * (1.0 - float(i) / trail_length)
				draw_line(start_pos, end_pos, trail_colors[i], width)

func _process(_delta):
	# Force redraw every frame to update trail
	if trail_enabled:
		queue_redraw()

func _on_body_entered(body):
	# Skip collision with source entity
	if body == source_entity:
		return
		
	# Check if collided with player
	if body.is_in_group("player"):
		# Deal damage to player if they have the function
		if body.has_method("take_damage"):
			var pos = global_position - (direction * 20)  # Position slightly behind projectile
			body.take_damage(damage, pos)
		
		# Create impact effect
		create_impact_effect()
		
		# Destroy projectile
		queue_free()
	
	# Check if collided with enemy
	elif body.is_in_group("enemy") and source_entity and source_entity.is_in_group("player"):
		# Deal damage to enemy if player shot this projectile
		if body.has_method("take_damage"):
			var knockback_dir = direction
			body.take_damage(damage, knockback_dir, 300)
			
		# Create impact effect
		create_impact_effect()
		
		# Destroy projectile
		queue_free()

# Create a simple impact effect
func create_impact_effect():
	# Try to load impact effect
	var effect_scene = null
	if ResourceLoader.exists("res://scenes/effects/ImpactEffect.tscn"):
		effect_scene = load("res://scenes/effects/ImpactEffect.tscn")
	elif ResourceLoader.exists("res://scenes/effects/HitEffect.tscn"):
		effect_scene = load("res://scenes/effects/HitEffect.tscn")
		
	if effect_scene and is_inside_tree():
		var effect = effect_scene.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = global_position
		
		# Orient effect based on projectile direction
		if effect.has_method("set_direction"):
			effect.set_direction(direction)
		
		# Play effect if it has a play method
		if effect.has_method("play"):
			effect.play()

# Add a collision exception to prevent hitting the source enemy
func add_collision_exception(body):
	# Store reference to the source entity
	source_entity = body 
