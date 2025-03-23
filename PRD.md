# Midnight Malice - Product Requirements Document

## Game Overview

Midnight Malice is a 2D side-scrolling action platformer with combat elements. The player controls a martial artist character fighting through levels filled with enemies, collecting points and power-ups along the way.

## Target Audience
- Primary: Action game enthusiasts, ages 13-35
- Secondary: Platformer fans, retro game enthusiasts
- Platforms: PC (Windows, Mac, Linux), with potential for console ports

## Core Gameplay Requirements

### Player Character

#### Movement
- Horizontal movement with acceleration and friction
- Jumping with variable height based on button press duration
- Double jump ability
- Wall sliding and wall jumping
- Dash ability with cooldown

#### Combat
- Melee attacks with combo system
- Special attacks when at full health
- Projectile attack option (fires through terrain)
- Projectiles deal 3x damage of regular attacks
- Damage invincibility frames after being hit
- Impactful knockback system for satisfying combat feel
- Visual hit effects and screen shake
- Brief time slowdown on impactful hits (hit pause)

### Enemies

#### Basic Enemy Structure
- All enemies inherit from base Enemy class
- Enemies must be in the "enemy" group
- Enemies emit "enemy_defeated" signal when defeated
- Enemies have visual feedback when taking damage
- Enemies have increased health (8x) to balance against powerful projectiles

#### Enemy Types
- **Enemy1**: Basic enemy, 50 points, low health/damage
- **Enemy2**: Medium enemy, 100 points, average health/damage
- **Enemy3**: Advanced enemy, 150 points, high health/damage
- Future enemy types will follow similar pattern with unique abilities

#### Enemy Behavior
- Idle state with random patrols
- Detection radius for player awareness
- Chase state when player is detected
- Attack state when in range
- Hurt and death states
- Melee and ranged attack capabilities
- Visual feedback during attacks and when taking damage

### Power-up System

#### Power-up Types
- **Health Power-up**: Restores player health
- **Shield Power-up**: Provides temporary invincibility
- **Projectile Power-up**: Grants special attack and auto-fires a projectile

#### Power-up Behavior
- Power-ups are animated with visual feedback
- Collected on contact with player
- Provide immediate effects when collected
- Distributed throughout levels at strategic points
- Visual and audio feedback on collection

### Game Systems

#### Health System
- Player has 100 max health by default
- Health is reduced by enemy attacks
- Health can be restored through pickups or score milestones
- **NO floating health bars** above player's head
- Death occurs when health reaches 0

#### Combat Feedback System
- Dynamic knockback based on attack strength
- Visual flash effects on hit
- Enemy recoil when attacking player
- Brief time dilation for impactful hits
- Upward knockback component for dramatic effect

#### Score System
- Different enemy types give different point values
- Every 500 points, player gains +10 health (up to max)
- Score is displayed in the Game HUD
- High scores will be saved (future implementation)

#### Game HUD
- Health bar in the UI (not above player)
- Energy/special attack bar
- Current score display
- Visual indicators for ability cooldowns (future)

## Technical Requirements

### Architecture
- Game built in Godot Engine
- Signal-based communication between components
- GameManager singleton for game state management
- Scene-based structure for modularity

### Performance Targets
- 60 FPS on mid-range hardware
- Efficient collision detection
- Optimized animations and effects

### Art Style
- 2D pixel art with modern touches
- Fluid character animations
- Distinct visual style for each enemy type
- Atmospheric background parallax

### Audio
- Sound effects for all player actions
- Enemy sound effects
- Background music that changes with gameplay intensity
- Audio mixing for proper balance

## Future Considerations

### Expandability
- Design for easy addition of new enemy types
- Level editor possibility
- Modding support potential

### Monetization
- Base game with potential for DLC content
- Cosmetic options
- No pay-to-win mechanics

## Quality Assurance

### Target Metrics
- Bug-free gameplay
- Consistent frame rate
- Intuitive controls
- Balanced difficulty

### Testing Strategy
- Automated unit tests for core systems
- Playtest sessions with target audience
- Beta testing phase before release

## Development Timeline
- See ROADMAP.md for detailed development timeline and milestones 