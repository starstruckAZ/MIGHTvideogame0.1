# Midnight Malice

A 2D action platformer game with dynamic combat mechanics and visual feedback.

## Game Overview

Midnight Malice is a side-scrolling action platformer where players control a martial artist fighting through levels filled with enemies. The game features a polished combat system with combo attacks, projectiles, and dramatic visual effects for a satisfying gameplay experience.

## Features

### Player Mechanics
- Fluid movement system with acceleration and deceleration
- Advanced jump mechanics (double jump, wall slide, wall jump)
- Dash ability with cooldown
- Two-stage combo melee attack system
- Special projectile attack at full health
- Dynamic hit reactions and knockback

### Enemy System
- Multiple enemy types with unique behaviors
- Advanced AI with detection, chase, and attack states
- Melee and ranged attack capabilities
- Visual feedback when taking damage
- Advanced knockback and hit reactions

### Combat System
- Impact-based combat with satisfying knockback effects
- Time slowdown effects on powerful hits
- Visual flash effects for hit feedback
- Projectiles that pass through terrain
- Enhanced recoil and physics for engaging combat feel

### Game Systems
- Health system with visual feedback
- Score system with points for defeating enemies
- Health bonuses at score milestones
- Game HUD with health, energy, and score display

## Controls

- **A/D or Left/Right Arrow**: Move left/right
- **W or Up Arrow**: Jump (press twice for double jump)
- **S or Down Arrow**: Duck (not implemented yet)
- **Space**: Attack (tap again for combo)
- **Shift**: Dash
- **E**: Special attack (when at full health)

## Development Status

The game is currently in alpha development. See the [Roadmap](ROADMAP.md) for more details on development progress and future plans.

## Technical Details

### Requirements
- Godot Engine 4.x

### Project Structure
- `scripts/`: Contains all game logic scripts
  - `Player.gd`: Player character controller
  - `Enemy.gd`: Base enemy class
  - `Enemy1.gd`, `Enemy2.gd`, `Enemy3.gd`: Specific enemy implementations
  - `Projectile.gd`: Projectile behavior
  - `GameManager.gd`: Core game state management
- `scenes/`: Contains game scenes
  - `Player.tscn`: Player character scene
  - `Main.tscn`: Main game scene
  - `enemies/`: Enemy scene files
  - `effects/`: Visual effect scenes
- `Assets/`: Game assets including sprites and sounds

### Collision System
The game uses the following collision layers:
- Layer 1: World/Terrain
- Layer 2: Player
- Layer 3: Enemies
- Layer 4: Projectiles

## Credits

- Game Development: [Your Name/Team]
- Sprite Assets: [Asset Sources]

## License

[License details] 