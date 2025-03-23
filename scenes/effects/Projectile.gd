extends Area2D

@export var speed = 400
@export var damage = 20
var direction = Vector2.RIGHT

# Trail effect
var trail_points = []
var max_trail_points = 10

func _ready():
	# Set initial rotation based on direction
	rotation = direction.angle()
	
	# Create particles for the trail
	var trail = $Trail if has_node("Trail") else null
	if not trail:
		# Add emitting particles
		var particles = GPUParticles2D.new()
		particles.name = "Trail"
		particles.amount = 20
		particles.lifetime = 0.5
		particles.local_coords = false
		particles.emitting = true
		
		# Create material
		var material = ParticleProcessMaterial.new()
		material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
		material.particle_flag_disable_z = true
		material.direction = Vector3(0, 0, 0)
		material.spread = 10.0
		material.gravity = Vector3(0, 0, 0)
		material.initial_velocity_min = 5.0
		material.initial_velocity_max = 10.0
		material.color = Color(1.0, 0.7, 0.2, 0.7)
		particles.process_material = material
		
		add_child(particles)

func _physics_process(delta):
	# Move projectile
	position += direction * speed * delta
	
	# Add trail effect
	if trail_points.size() < max_trail_points:
		trail_points.append(position)
	else:
		trail_points.pop_front()
		trail_points.append(position)

func _on_body_entered(body):
	# Check if hit an enemy
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Explosion effect
	_create_impact_effect()
	
	# Remove projectile
	queue_free()

func _on_lifetime_timer_timeout():
	queue_free()

func _create_impact_effect():
	# Create an explosion when the projectile impacts
	var impact = GPUParticles2D.new()
	impact.position = position
	impact.emitting = true
	impact.one_shot = true
	impact.explosiveness = 0.9
	impact.amount = 30
	
	# Create material
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 5.0
	material.direction = Vector3(0, 0, 0)
	material.spread = 180.0
	material.gravity = Vector3(0, 0, 0)
	material.initial_velocity_min = 30.0
	material.initial_velocity_max = 80.0
	material.scale_min = 2.0
	material.scale_max = 4.0
	material.color = Color(1.0, 0.6, 0.1, 0.8)
	impact.process_material = material
	
	# Add to scene
	get_parent().add_child(impact)
	
	# Auto-destroy after particles finish
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.autostart = true
	impact.add_child(timer)
	timer.timeout.connect(func(): impact.queue_free()) 