# Midnight Malice - Game Setup Instructions
# This file contains instructions for setting up the game scene structure.

"""
To properly set up the game with the HUD and score system, follow these steps in the Godot Editor:

1. Open your main game scene (Main.tscn or your level scene)

2. Add the GameHUD scene:
   - Right-click in the scene tree and select "Instance Child Scene"
   - Navigate to "res://scenes/UI/GameHUD.tscn" and select it
   - The GameHUD should be added as a direct child of the main scene node

3. Add the GameManager node:
   - Right-click in the scene tree and select "Add Child Node"
   - Select "Node" type
   - Rename it to "GameManager"
   - In the Inspector panel, click the script dropdown and select "Load"
   - Navigate to "res://scripts/GameManager.gd" and select it

4. Connect the GameManager signals to the GameHUD:
   - Select the GameManager node in the scene tree
   - Go to the Node tab in the Inspector (the tab with signal icon)
   - Find the "score_changed" signal and connect it to the GameHUD node
     - Choose the "update_score" method
   - Find the "player_health_changed" signal and connect it to the GameHUD node
     - Choose the "update_health" method

5. For each enemy in your scene:
   - Make sure they inherit from the base Enemy class
   - Verify they have the "enemy_defeated" signal
   - Make sure they are in the "enemy" group

The GameManager will automatically detect enemies added to the scene and connect
to their signals to update the score when they're defeated.

Scoring system:
- Enemy1: 50 points
- Enemy2: 100 points
- Enemy3: 150 points
- Other enemies: 25 points
- Every 500 points, player gets +10 health

Feel free to modify the scoring values in the GameManager.gd script.
"""

# This file is for reference only and doesn't need to be attached to any node 