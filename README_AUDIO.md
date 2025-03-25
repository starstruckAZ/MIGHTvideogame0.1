# Audio System Documentation

## Overview
The game uses a centralized AudioManager system to handle all sound effects and music. The AudioManager is implemented as a singleton that can be accessed from anywhere in the game.

## Sound Effects
The following sound effects are implemented:

### Player
- `player_jump` - When the player jumps
- `player_land` - When the player lands after jumping
- `player_attack` - When the player performs a melee attack
- `player_hit` - When the player takes damage
- `player_death` - When the player dies
- `player_dash` - When the player performs a dash
- `player_projectile` - When the player fires a projectile

### Enemies
- `enemy_hit` - When an enemy takes damage
- `enemy_death` - When an enemy dies
- `enemy_attack` - When an enemy attacks

### UI
- `button_click` - When a UI button is clicked
- `score_increase` - When the player's score increases
- `health_pickup` - When the player collects a health pickup

## Music
The game includes the following music tracks:
- `main_menu` - Plays on the main menu
- `gameplay` - Plays during normal gameplay
- `boss_battle` - Plays during boss battles

## Implementation
The AudioManager is implemented in `scripts/AudioManager.gd` and is automatically loaded as a singleton in the Godot project. It provides methods for playing sound effects and music with volume and pitch control.

### Playing Sound Effects
```gdscript
# Example usage
if get_node_or_null("/root/AudioManager"):
    get_node("/root/AudioManager").play_sfx("player_jump", 0.8, 1.0)
```

Parameters:
- `sound_name` - The name of the sound effect to play
- `volume_scale` - Volume scale (0.0 to 1.0) [optional]
- `pitch_scale` - Pitch scale (default: 1.0) [optional]

### Playing Music
```gdscript
# Example usage
if get_node_or_null("/root/AudioManager"):
    get_node("/root/AudioManager").play_music("gameplay", 1.0)
```

Parameters:
- `music_name` - The name of the music track to play
- `fade_time` - Fade-in time in seconds (default: 1.0) [optional]

## Audio Files
All audio files should be placed in the following directories:
- Sound Effects: `Assets/Audio/SFX/`
- Music: `Assets/Audio/Music/`

## Adding New Sounds
To add new sounds to the game:
1. Add the sound file to the appropriate directory
2. Add the sound path to the `sfx_paths` or `music_paths` dictionary in `AudioManager.gd`
3. Use the `play_sfx` or `play_music` method to play the sound

## Volume Control
The AudioManager provides methods for controlling the volume of sound effects and music:
```gdscript
# Set master volume (0.0 to 1.0)
AudioManager.set_master_volume(0.8)

# Set SFX volume (0.0 to 1.0)
AudioManager.set_sfx_volume(0.7)

# Set music volume (0.0 to 1.0)
AudioManager.set_music_volume(0.5)
``` 