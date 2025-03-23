@tool
extends EditorScript

# This script is used to set up the player's AnimatedSprite2D with all animations
# Run this script from the Godot editor to create the SpriteFrames resource

func _run():
	# Create a new SpriteFrames resource
	var sprite_frames = SpriteFrames.new()
	
	# Add all animations
	add_animation(sprite_frames, "idle", "res://Assets/Sprites/Martial Hero 2/Sprites/Idle.png", 8, 0.1)
	add_animation(sprite_frames, "run", "res://Assets/Sprites/Martial Hero 2/Sprites/Run.png", 8, 0.1)
	add_animation(sprite_frames, "jump", "res://Assets/Sprites/Martial Hero 2/Sprites/Jump.png", 2, 0.1)
	add_animation(sprite_frames, "fall", "res://Assets/Sprites/Martial Hero 2/Sprites/Fall.png", 2, 0.1)
	add_animation(sprite_frames, "attack1", "res://Assets/Sprites/Martial Hero 2/Sprites/Attack1.png", 6, 0.05)
	add_animation(sprite_frames, "attack2", "res://Assets/Sprites/Martial Hero 2/Sprites/Attack2.png", 6, 0.05)
	add_animation(sprite_frames, "take_hit", "res://Assets/Sprites/Martial Hero 2/Sprites/Take hit.png", 4, 0.1)
	add_animation(sprite_frames, "death", "res://Assets/Sprites/Martial Hero 2/Sprites/Death.png", 6, 0.1)
	
	# Save the SpriteFrames resource
	var err = ResourceSaver.save(sprite_frames, "res://resources/player_frames.tres")
	if err != OK:
		print("Error saving player_frames.tres: ", err)
	else:
		print("Successfully saved player_frames.tres")

# Helper function to add animation from spritesheet
func add_animation(sprite_frames: SpriteFrames, anim_name: String, spritesheet_path: String, frames_count: int, frame_time: float):
	if not sprite_frames.has_animation(anim_name):
		sprite_frames.add_animation(anim_name)
	
	# Load the spritesheet
	var texture = load(spritesheet_path)
	if not texture:
		print("Failed to load texture: ", spritesheet_path)
		return
	
	# Calculate frame size (assuming frames are equal size and arranged horizontally)
	var frame_width = texture.get_width() / frames_count
	var frame_height = texture.get_height()
	
	# Clear existing frames
	sprite_frames.clear(anim_name)
	
	# Add frames to the animation
	for i in range(frames_count):
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = texture
		atlas_texture.region = Rect2(i * frame_width, 0, frame_width, frame_height)
		sprite_frames.add_frame(anim_name, atlas_texture, frame_time)
	
	print("Added animation: ", anim_name, " with ", frames_count, " frames") 