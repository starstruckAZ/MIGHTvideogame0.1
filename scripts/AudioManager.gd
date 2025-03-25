extends Node

# Constants for sound volumes
const MASTER_VOLUME = 1.0
const SFX_VOLUME = 0.8
const MUSIC_VOLUME = 0.5

# Placeholder sound for missing audio files
var placeholder_sound = null

# Dictionary mapping sound effect names to preloaded audio resources
var sound_effects = {}

# Music paths
var music_paths = {
	"main_menu": "res://Assets/Audio/Music/main_menu.ogg",
	"gameplay": "res://Assets/Audio/Music/gameplay.ogg",
	"boss_battle": "res://Assets/Audio/Music/boss_battle.ogg"
}

# Array of available audio stream players (created dynamically)
var available_players = []
# Maximum number of simultaneous sound effects
const MAX_PLAYERS = 16

# AudioStreamPlayers for music
var music_player: AudioStreamPlayer
var current_music: String = ""

func _ready():
	# Create placeholder sound (1 second silent audio)
	placeholder_sound = AudioStreamWAV.new()
	placeholder_sound.format = AudioStreamWAV.FORMAT_16_BITS
	placeholder_sound.mix_rate = 44100
	placeholder_sound.stereo = false
	
	# Create silent audio data (can't multiply array by integer in GDScript)
	var silence_data = PackedByteArray()
	silence_data.resize(44100 * 2) # 1 second of silence (2 bytes per sample for 16-bit)
	for i in range(silence_data.size()):
		silence_data[i] = 0
	
	placeholder_sound.data = silence_data
	
	# Initialize sound effects dictionary with safe loading
	_initialize_sound_effects()
	
	# Create a pool of AudioStreamPlayer nodes
	for i in range(MAX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"  # Assign to SFX bus
		add_child(player)
		available_players.append(player)
		
		# Connect the finished signal to make the player available again
		player.connect("finished", _on_sound_finished.bind(player))
	
	print("AudioManager initialized with " + str(MAX_PLAYERS) + " audio players")
	
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	music_player.volume_db = linear_to_db(MUSIC_VOLUME)
	add_child(music_player)
	
	# Set up audio buses if not already set up
	_setup_audio_buses()

func _setup_audio_buses():
	# Create SFX and Music buses if they don't exist
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")
		
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")

# Initialize sound effects with safe loading to handle missing files
func _initialize_sound_effects():
	# Define all sound paths
	var sound_paths = {
		# Player sounds
		"player_hit": "res://Assets/Audio/SFX/player_hit.wav",
		"player_death": "res://Assets/Audio/SFX/player_death.wav",
		"player_projectile": "res://Assets/Audio/SFX/player_projectile.wav",
		"player_jump": "res://Assets/Audio/SFX/player_jump.wav",
		"player_land": "res://Assets/Audio/SFX/player_land.wav",
		"player_footstep": "res://Assets/Audio/SFX/player_footstep.wav",
		
		# Enemy sounds
		"enemy_hit": "res://Assets/Audio/SFX/enemy_hit.wav",
		"enemy_death": "res://Assets/Audio/SFX/enemy_death.wav",
		"enemy_attack": "res://Assets/Audio/SFX/enemy_attack.wav",
		
		# UI sounds
		"button_press": "res://Assets/Audio/SFX/button_press.wav",
		"menu_select": "res://Assets/Audio/SFX/menu_select.wav",
		"game_over": "res://Assets/Audio/SFX/game_over.wav",
		"level_complete": "res://Assets/Audio/SFX/level_complete.wav",
		"score_increase": "res://Assets/Audio/SFX/score_increase.wav",
		
		# Environment sounds
		"door_open": "res://Assets/Audio/SFX/door_open.wav",
		"pickup_item": "res://Assets/Audio/SFX/pickup_item.wav",
		"powerup": "res://Assets/Audio/SFX/powerup.wav"
	}
	
	# Try to load each sound, use placeholder for missing files
	for sound_name in sound_paths:
		var path = sound_paths[sound_name]
		if ResourceLoader.exists(path):
			sound_effects[sound_name] = load(path)
			print("Loaded sound: " + sound_name)
		else:
			# Don't use placeholder sounds anymore
			print("Skipping missing sound: " + sound_name)

# Play a sound effect by name with optional volume adjustment and pitch
func play_sound(sound_name: String, volume_db: float = 0.0, pitch_scale: float = 1.0):
	if not sound_effects.has(sound_name):
		push_warning("Sound effect not found: " + sound_name)
		return
	
	# Find an available audio player
	var player = _get_available_player()
	if player:
		player.stream = sound_effects[sound_name]
		player.volume_db = volume_db
		player.pitch_scale = pitch_scale
		player.play()
	else:
		push_warning("No available audio players to play: " + sound_name)

# Get an available audio player from the pool
func _get_available_player() -> AudioStreamPlayer:
	for player in available_players:
		if not player.playing:
			return player
	
	# If all players are busy, use the oldest one (first in the array)
	if available_players.size() > 0:
		var oldest_player = available_players[0]
		# Move the player to the end of the array to maintain rotation
		available_players.erase(oldest_player)
		available_players.append(oldest_player)
		oldest_player.stop()
		return oldest_player
	
	return null

# Callback for when a sound finishes playing
func _on_sound_finished(player: AudioStreamPlayer):
	# The player is automatically available for reuse
	pass

# Play a positional sound (2D) at the specified position
func play_sound_positional(sound_name: String, position: Vector2, volume_db: float = 0.0, pitch_scale: float = 1.0):
	if not sound_effects.has(sound_name):
		push_warning("Sound effect not found: " + sound_name)
		return
	
	# Create a temporary AudioStreamPlayer2D for positional audio
	var player2d = AudioStreamPlayer2D.new()
	player2d.stream = sound_effects[sound_name]
	player2d.volume_db = volume_db
	player2d.pitch_scale = pitch_scale
	player2d.position = position
	player2d.bus = "SFX"
	
	# Add the player to the scene tree temporarily
	add_child(player2d)
	player2d.play()
	
	# Connect to the finished signal to remove the node when done
	player2d.connect("finished", _on_positional_sound_finished.bind(player2d))

# Callback for when a positional sound finishes playing
func _on_positional_sound_finished(player: AudioStreamPlayer2D):
	player.queue_free()

# Play background music
func play_music(music_name: String, fade_time: float = 1.0):
	if current_music == music_name:
		return
	
	if not music_paths.has(music_name):
		push_warning("Music '%s' not found in music_paths dictionary." % music_name)
		return
	
	# Check if music file exists first
	if not ResourceLoader.exists(music_paths[music_name]):
		push_warning("Music file '%s' does not exist." % music_paths[music_name])
		return
	
	# If already playing something, fade out then start new music
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_time)
		tween.tween_callback(Callable(self, "_change_music").bind(music_name))
	else:
		_change_music(music_name)
	
	current_music = music_name

# Helper to change the music track
func _change_music(music_name: String):
	music_player.stream = load(music_paths[music_name])
	music_player.volume_db = linear_to_db(MUSIC_VOLUME)
	music_player.play()

# Stop all sounds
func stop_all_sounds():
	for player in available_players:
		player.stop()

# Stop music
func stop_music(fade_time: float = 1.0):
	if fade_time > 0 and music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_time)
		tween.tween_callback(Callable(music_player, "stop"))
	else:
		music_player.stop()
	
	current_music = ""

# Set master volume (0.0 to 1.0)
func set_master_volume(volume: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(clamp(volume, 0.0, 1.0)))

# Set SFX volume (0.0 to 1.0)
func set_sfx_volume(volume: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(clamp(volume, 0.0, 1.0)))
	
# Set music volume (0.0 to 1.0)
func set_music_volume(volume: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(clamp(volume, 0.0, 1.0))) 
