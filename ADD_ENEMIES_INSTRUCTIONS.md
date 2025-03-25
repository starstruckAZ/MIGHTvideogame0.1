# Enemy Placement Scripts Instructions

This document provides information on how to use the enemy placement scripts to add and organize enemies in your level.

## Available Scripts

The following scripts are available for enemy placement:

1. **add_more_enemies.gd** - Adds a series of basic enemies with simple patrol routes.
2. **create_vertical_section.gd** - Creates a vertical section with enemies patrolling at different heights.
3. **create_challenge_section.gd** - Creates a challenging section with enemies in complex patrol patterns.

## How to Use the Scripts

All scripts can be run as Editor Scripts in Godot:

1. Open your scene in the Godot editor
2. Go to the Script Editor
3. Click on File -> Open, then select one of the scripts from the scripts folder
4. Click on the "Run" button in the script editor (or press Ctrl+Shift+X)

## Prerequisites

Before running these scripts, make sure your scene has:

1. A node named "Enemies" - This should be a Node2D that will contain all enemy instances
2. A node named "PatrolPoints" - This should be a Node2D that will contain all patrol point markers

## Script Details

### add_more_enemies.gd

This script adds basic enemies with simple patrol paths. It:
- Creates patrol point pairs for each enemy
- Alternates between different enemy types
- Positions enemies in a linear progression

### create_vertical_section.gd

This script creates a vertical section with enemies at different heights:
- Creates patrol points at various heights
- Positions enemies to patrol horizontally at each height level
- Provides vertical challenges for the player

### create_challenge_section.gd

This script creates a more challenging section with complex enemy movements:
- Creates a grid of patrol points
- Sets up enemies with complex patrol paths (rectangles, diamonds, etc.)
- Makes enemies slightly stronger for an additional challenge

## Audio Effects

All enemies have sound effects integrated:
- Enemy hit sounds when taking damage
- Death sounds when defeated
- Attack sounds when they attack the player

## Best Practices

1. Run the scripts in order: first add basic enemies, then vertical sections, then challenge sections
2. Test the level after each script to ensure proper difficulty progression
3. Adjust patrol points manually if needed after script execution
4. Add environmental elements around enemy placements for better level design

## Troubleshooting

If you encounter issues:
1. Ensure your scene has the required "Enemies" and "PatrolPoints" containers
2. Check the console output for any error messages
3. Make sure enemy scene paths in the scripts match your project structure
4. Verify that the AudioManager is properly set up for sound effects

## Example Usage Sequence

For a complete level setup:
1. Run add_more_enemies.gd to create the basic enemy progression
2. Run create_vertical_section.gd to add a vertical challenge section
3. Run create_challenge_section.gd to add the final challenging section
4. Test and adjust as needed 