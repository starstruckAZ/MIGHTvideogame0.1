extends Node

func _ready():
	# Register singletons
	register_audio_manager()

func register_audio_manager():
	# Create an instance of the AudioManager
	var audio_manager = load("res://scripts/AudioManager.gd").new()
	audio_manager.name = "AudioManager"
	
	# Add it to the root scene as an autoload/singleton
	get_tree().root.call_deferred("add_child", audio_manager)
	
	# Wait until it's added to the scene tree
	await audio_manager.ready
	
	print("AudioManager initialized successfully") 