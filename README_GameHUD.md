# Midnight Malice Game HUD System

## Overview
The Game HUD system provides a customizable heads-up display for your game, showing player health, energy, and score. The system is designed to integrate seamlessly with the GameManager and enemy system.

## Files in the System
- `scenes/UI/GameHUD.tscn`: The main HUD scene with health bar, energy bar, and score display
- `scenes/UI/GameHUD.gd`: Script that handles updating the HUD elements
- `scripts/GameManager.gd`: Manages game state, player health, and score
- `scripts/Enemy.gd`: Base enemy class with added enemy_defeated signal
- `scripts/HudTester.gd`: Testing utility for verifying HUD connections
- `GameSetupInstructions.gd`: Documentation on setting up the system

## Features
- **Health Bar**: Displays current player health as a percentage
- **Energy Bar**: Shows energy level (currently tied to health)
- **Score Display**: Dynamic score counter that updates as enemies are defeated
- **Score System**: Different enemies give different scores
- **Health Bonus**: Player gets health bonus at score milestones (every 500 points)

## Setup Instructions

### Setting Up the Game HUD
1. Open your main game scene (Main.tscn or your level scene)
2. Add the GameHUD scene:
   - Right-click in the scene tree and select "Instance Child Scene"
   - Navigate to "res://scenes/UI/GameHUD.tscn" and select it
   - The GameHUD should be added as a direct child of the main scene node

### Setting Up the Game Manager
1. Add the GameManager node:
   - Right-click in the scene tree and select "Add Child Node"
   - Select "Node" type
   - Rename it to "GameManager"
   - In the Inspector panel, click the script dropdown and select "Load"
   - Navigate to "res://scripts/GameManager.gd" and select it

### Connecting Signals
1. Select the GameManager node in the scene tree
2. Go to the Node tab in the Inspector (the tab with signal icon)
3. Find the "score_changed" signal and connect it to the GameHUD node
   - Choose the "update_score" method
4. Find the "player_health_changed" signal and connect it to the GameHUD node
   - Choose the "update_health" method

### Enemy Setup
For each enemy in your scene:
1. Make sure they inherit from the base Enemy class
2. Verify they have the "enemy_defeated" signal
3. Make sure they are in the "enemy" group

## Testing the System
You can test your HUD integration using the HudTester:

1. Add a Node to your scene
2. Attach the `scripts/HudTester.gd` script to it
3. Run the scene
4. Use the buttons to simulate damage, healing, and score changes

## Customization

### Modifying Score Values
Edit the `enemy_score_values` dictionary in `GameManager.gd`:

```gdscript
var enemy_score_values = {
    "Enemy1": 50,
    "Enemy2": 100,
    "Enemy3": 150
}
```

### Changing Health Bonus Threshold
Modify the score milestone check in the `add_score` function:

```gdscript
func add_score(points: int) -> void:
    score += points
    emit_signal("score_changed", score)
    
    # Change 500 to your desired milestone value
    if score % 500 == 0:
        # Change 10 to your desired health bonus amount
        player_health = min(player_health + 10, player_max_health)
        emit_signal("player_health_changed", player_health, player_max_health)
```

### Customizing HUD Appearance
Open the `scenes/UI/GameHUD.tscn` scene and modify:
- Font styles, sizes, and colors
- Bar sizes, colors, and positions
- Labels and text

## Troubleshooting
- **HUD not updating?** Verify signal connections between GameManager and GameHUD
- **Score not increasing?** Check that enemies:
  - Inherit from Enemy.gd
  - Are in the "enemy" group
  - Emit the "enemy_defeated" signal when defeated
- **Can't find the GameManager?** The GameHUD script tries multiple paths; ensure it's in one of those locations

## API Reference

### GameHUD
- `update_health(new_health, max_health)`: Updates the health bar
- `update_score(new_score)`: Updates the score display

### GameManager
- `update_player_health(new_health)`: Sets player health and emits signal
- `add_score(points)`: Adds to player score and emits signal
- `player_death()`: Handles player death logic

### Signals
- `score_changed(score)`: Emitted when score changes
- `player_health_changed(health, max_health)`: Emitted when health changes
- `player_died`: Emitted when player dies
- `game_over`: Emitted when game is over
- `enemy_defeated`: Emitted when an enemy is defeated 