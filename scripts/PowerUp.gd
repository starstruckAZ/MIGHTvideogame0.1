extends Area2D

class_name PowerUp

# PowerUp type enumeration
enum PowerUpType {
	HEALTH,
	SHIELD,
	PROJECTILE
}

# Properties
var powerup_type = PowerUpType.HEALTH
var rotation_speed = 1.0  # Reduced from 2.0
var bob_height = 3.0      # Reduced from 5.0
var bob_speed = 1.5       # Slightly reduced for gentler bobbing

# Animation variables
var original_position = Vector2.ZERO
var time_passed = 0.0

# References
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var animation_player = $AnimationPlayer if has_node("AnimationPlayer") else null

# Shield variables (will be set on player)
var shield_hit_count = 2  # Number of hits the shield will absorb
var health_restore_amount = 50  # Amount of health restored (half of player's max health)

func _ready():
	# Set up collision
	collision_layer = 0  # No collision layer for the powerup itself
	collision_mask = 2   # Player is on layer 2
	
	# Connect body entered signal
	connect("body_entered", _on_body_entered)
	
	# Store the original position for bob animation
	original_position = position
	
	# Set sprite based on powerup type
	_set_sprite()

func _process(delta):
	# Rotate the powerup
	rotation += rotation_speed * delta
	
	# Bob the powerup up and down
	time_passed += delta
	position.y = original_position.y + sin(time_passed * bob_speed) * bob_height

func _set_sprite():
	# Load sprite based on powerup type
	var texture_path = ""
	match powerup_type:
		PowerUpType.HEALTH:
			texture_path = "res://Assets/Sprites/PowerUp/Health.png"
		PowerUpType.SHIELD:
			texture_path = "res://Assets/Sprites/PowerUp/Shield.png"
		PowerUpType.PROJECTILE:
			texture_path = "res://Assets/Sprites/PowerUp/Projectile.png"
	
	# Load texture if it exists
	if ResourceLoader.exists(texture_path):
		sprite.texture = load(texture_path)
	else:
		push_error("PowerUp texture not found: " + texture_path)

func _on_body_entered(body):
	# Check if the body is the player
	if body.is_in_group("player"):
		# Apply powerup effect
		apply_powerup(body)
		
		# Play pickup sound
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_sound("pickup_item", 0.0)
		
		# Queue free to remove the powerup
		queue_free()

func apply_powerup(player):
	match powerup_type:
		PowerUpType.HEALTH:
			# Restore health
			if player.has_method("heal"):
				player.heal(health_restore_amount)
				print("Health powerup applied: +", health_restore_amount)
			else:
				push_warning("Player does not have heal method!")
		
		PowerUpType.SHIELD:
			# Apply shield
			if player.get("is_invincible") != null:
				player.is_invincible = true
				
				# Create a timer to maintain invincibility for a duration
				var duration = 10.0  # Shield lasts for 10 seconds
				
				# Store player reference for the callback
				var player_ref = weakref(player)
				
				# Reset shield after duration
				var shield_timer = get_tree().create_timer(duration)
				shield_timer.timeout.connect(_on_shield_expired.bind(player_ref))
				
				print("Shield powerup applied: Invincible for", duration, "seconds")
			else:
				push_warning("Player does not have is_invincible property!")
		
		PowerUpType.PROJECTILE:
			# Enable projectile ability
			if player.has_method("_on_special_attack_activated"):
				# Set player health to max to enable special attack
				player.health = player.max_health
				
				# Trigger special attack availability
				player.emit_signal("special_ready_changed", true)
				
				# Automatically fire a projectile without consuming health
				if player.has_method("fire_projectile"):
					player.fire_projectile()
					
					# Play projectile sound
					if get_node_or_null("/root/AudioManager"):
						get_node("/root/AudioManager").play_sound("player_projectile", 0.9)
				
				print("Projectile powerup applied: Special attack ready + projectile fired")
			else:
				push_warning("Player does not have _on_special_attack_activated method!")

# Set the powerup type and update the sprite
func set_type(type):
	powerup_type = type
	if is_inside_tree():
		_set_sprite()

# Called when shield effect expires
func _on_shield_expired(player_ref):
	var player = player_ref.get_ref()
	if player:
		player.is_invincible = false
		print("Shield effect expired")

# ... rest of the existing code ... 