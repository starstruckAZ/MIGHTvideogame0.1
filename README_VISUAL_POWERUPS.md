# Visual PowerUp Placement System

This system allows you to visually place and position powerup icons directly in the Godot editor, making it much easier to distribute powerups across your level.

## Setup Instructions

1. First, run the setup script to add the visual powerup icons to your main level:
   - Open Godot Editor
   - Go to the Script tab
   - Open the script `scripts/add_visual_powerups_to_level.gd`
   - Click the "Run" button at the top-right of the script editor

2. After running the script:
   - Open `MainLevel.tscn` 
   - You should see translucent powerup icons already placed across the level
   - These icons are only visible in the editor, not during gameplay

## How to Use

### Moving Existing Powerups
1. Select any powerup icon in the scene hierarchy or directly in the viewport
2. Use the Move tool to drag it to a new position
3. You can also adjust its position precisely in the Inspector panel

### Adding New Powerups
To add more powerups:
1. Select the appropriate group (HealthPowerUps, ShieldPowerUps, or ProjectilePowerUps)
2. Right-click and select "Add Child Node"
3. Choose "Sprite2D"
4. In the Inspector, set:
   - Texture: The appropriate powerup texture
   - Modulate: Set Alpha to 0.7 for visibility
   - Position: Where you want the powerup
   - Metadata: Add "powerup_type" with value 0 (Health), 1 (Shield), or 2 (Projectile)

### Tips for Good Placement
- Place powerups in accessible areas (not inside terrain)
- Distribute them evenly across the level
- Place different types in strategic locations
- Health powerups are good before difficult sections
- Shield powerups work well near hazards
- Projectile powerups are valuable before enemy groups

## How It Works

This system uses editor-only sprites that are converted to actual powerups when the game runs:

1. `VisualPowerUpPlacement.tscn` contains sprite nodes for each powerup
2. At runtime, `VisualPowerUpPlacement.gd` converts these sprites to actual powerup objects
3. The original sprites are hidden during gameplay
4. Each powerup keeps the same position, type, and properties

## Troubleshooting

- If powerups aren't appearing in-game, check the Output panel for error messages
- Make sure each sprite has the correct "powerup_type" metadata set
- Confirm the powerup textures are correctly assigned
- If editor sprites are visible during gameplay, check that `VisualPowerUpPlacement.gd` is properly converting them

## Editing the PowerUps

After adding the visual system, you can edit any powerup by:
1. Opening MainLevel.tscn
2. Expanding the VisualPowerUpPlacement node
3. Finding the powerup you want to modify
4. Using the move, rotate, or scale tools in the editor
5. Saving the scene

Remember, these changes only affect the visual placement - the actual powerup behavior is still defined in PowerUp.gd. 