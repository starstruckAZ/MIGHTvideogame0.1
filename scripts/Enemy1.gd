extends "res://scripts/Enemy.gd"

class_name Enemy1

# Enemy1 - Basic melee attacker

# Attack combo variables
var attack_combo = 1
var attack_combo_timer = 0.0
var attack_combo_timeout = 1.0

func _ready():
	# Call the parent _ready function first
	super._ready()
	
	# Initialize Enemy1's properties
	max_health = 500 # Tank enemy with high health
	health = max_health
	attack_damage = 15
	move_speed = 80.0
	detection_radius = 250.0
	attack_range = 60.0
	attack_cooldown = 1.0
	
	# Set initial state
	current_state = IDLE

func _physics_process(delta):
	# Update attack combo timer
	if attack_combo > 0:
		attack_combo_timer -= delta
		if attack_combo_timer <= 0:
			attack_combo = 0
	
	# Call parent implementation
	super._physics_process(delta)

func attack():
	# Start attack cooldown
	can_attack = false
	attack_timer = attack_cooldown
	
	# Handle attack combo
	if attack_combo > 0 and attack_combo_timer > 0:
		attack_combo = (attack_combo % 2) + 1  # Toggle between 1 and 2
	else:
		attack_combo = 1
	
	attack_combo_timer = attack_combo_timeout
	
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
		
		# Create a timer to disable the attack area after a short duration
		if is_inside_tree():
			var timer = get_tree().create_timer(0.3)  # 0.3 seconds attack duration
			timer.timeout.connect(func(): 
				if attack_area and is_instance_valid(attack_area):
					if attack_area.has_node("CollisionShape2D"):
						attack_area.get_node("CollisionShape2D").disabled = true
					attack_area.monitoring = false
			)
