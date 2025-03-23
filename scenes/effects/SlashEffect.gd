extends AnimatedSprite2D

func _ready():
	# Connect to the animation_finished signal
	self.animation_finished.connect(_on_animation_finished)
	
	# Auto-play the slash animation
	play()

func _on_animation_finished():
	# Delete the effect once animation is complete
	queue_free() 