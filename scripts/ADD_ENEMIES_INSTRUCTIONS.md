# Enemy Addition Instructions

These scripts will add more enemies to your game map, bringing the total to over 14 enemies with various patrol patterns and behaviors.

## Prerequisites

- Make sure you have your `MainLevel.tscn` open in the Godot Editor
- Ensure you have `Enemy1.tscn`, `Enemy2.tscn`, and `Enemy3.tscn` in your `scenes/enemies/` directory

## Adding Enemies

There are three scripts provided, each adding different types of enemy patterns to your map:

1. **add_more_enemies.gd** - Adds more enemies along a horizontal path
2. **create_vertical_section.gd** - Creates a vertical section with enemies at different heights
3. **create_challenge_section.gd** - Creates a challenging section with enemies following complex patrol paths

### How to Use

Run each script in order through the Godot Editor:

1. Make sure your MainLevel scene is open in the editor
2. Go to the Script Editor
3. Open one of the scripts
4. Click the "Run" button (or press Ctrl+Shift+X) to execute the script in the editor context
5. Check the Output panel for information on what has been added
6. Save your scene after running all scripts

### Results

After running all three scripts, you will have:

- **Horizontal section**: Additional enemies with horizontal patrol paths
- **Vertical section**: Enemies at different heights with horizontal patrol paths
- **Challenge section**: Enemies with complex patrol patterns like rectangles, diagonals, and zigzags

The total number of enemies should be over 14, providing a more challenging gameplay experience.

## Script Details

### add_more_enemies.gd

This script adds horizontal patrol routes by:
- Finding how many enemies already exist
- Calculating how many more to add to reach 14
- Creating new patrol points continuing from existing ones
- Adding new enemies that patrol between those points

### create_vertical_section.gd

This script creates a vertical challenge area by:
- Adding patrol points at different heights
- Creating enemies that patrol horizontally at each height
- Providing a varied vertical challenge for the player

### create_challenge_section.gd

This script creates a challenging section with complex patrol patterns:
- Creates a grid of patrol points
- Defines different patrol paths (rectangle, diagonal, zigzag)
- Assigns enemies to follow these complex paths

## Customization

You can modify these scripts to adjust:
- The position of the new sections (change the base_x and base_y values)
- The number and spacing of enemies (adjust the loop ranges and point_spacing)
- The types of enemies used (modify the enemy_scenes array)
- The patrol patterns (particularly in create_challenge_section.gd)

## Troubleshooting

If you encounter issues:
- Ensure your scene has "Enemies" and "PatrolPoints" containers
- Check the Output panel for error messages
- Make sure all enemy scene paths are correct 