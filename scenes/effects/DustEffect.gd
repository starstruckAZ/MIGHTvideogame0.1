extends GPUParticles2D

func _ready():
	# Connect to finished signal
	self.finished.connect(_on_finished)
	
	# Start emitting
	emitting = true

func _on_finished():
	# Queue free when particles are done
	queue_free() 