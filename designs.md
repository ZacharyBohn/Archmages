
# Elemental Conquest Game Design

## 1. Core Concept

Elemental Conquest is a real-time strategy (RTS) game where players manage a network of interconnected worlds. The goal is to defend your territory, expand to new worlds, and ultimately conquer the entire map. This is achieved by managing resources, building infrastructure, and commanding a force of magical combatants.

## 2. Visual Style

The game will use a minimalist visual style, with simple shapes and text representing all elements.
- **Worlds:** Circles
- **Connections:** Lines between circles
- **Infrastructure:** Icons or text labels within a world's popup
- **Units:** Simple icons or colored dots

## 3. Core Gameplay Loop

1.  **Start:** The player begins with a single, balanced world.
2.  **Build:** The player builds and upgrades infrastructure to generate resources.
3.  **Defend:** Wild elementals periodically spawn on worlds and will damage infrastructure if not defeated.
4.  **Expand:** The player trains mages and sends them to conquer neighboring worlds.
5.  **Conquer:** The player wins by conquering all worlds on the map.

## 4. Worlds

Worlds are the central focus of the game. Each world is a node in a graph, connected to others by paths.

### World Types and Resource Affinities

Each world has an affinity for different resource types, represented by a multiplier on the base generation rate of infrastructure.

| World Type    | Water Affinity | Metal Affinity | Food Affinity | Aura Affinity | Description                                         |
|---------------|----------------|----------------|---------------|---------------|-----------------------------------------------------|
| **Water**     | 2.0x           | 0.5x           | 1.0x          | 1.0x          | Abundant in water, but poor for mining.             |
| **Mining**    | 0.5x           | 2.0x           | 0.5x          | 1.0x          | Rich in metals, but arid and difficult to farm.     |
| **Farming**   | 1.0x           | 0.5x           | 2.0x          | 1.0x          | Fertile land, ideal for food production.            |
| **Aura**      | 1.0x           | 1.0x           | 1.0x          | 2.0x          | Steeped in magic, perfect for generating aura.      |
| **Desert**    | 0.25x          | 1.25x          | 0.25x         | 0.5x          | Very dry and barren, minimal resources.             |
| **Verdant**   | 1.0x           | 1.0x           | 1.0x          | 1.0x          | A balanced world with no particular strengths.      |

### Wild Elementals

-   Elementals are hostile NPC units that spawn periodically on player-controlled worlds.
-   They will move towards and attack a random piece of infrastructure.
-   If they destroy the infrastructure, they will move to another.
-   They must be defeated by the player's mages.

## 5. Resources

There are four primary resources:

-   **Water:** Essential for farms and training mages.
-   **Metal:** Used to build and upgrade all infrastructure.
-   **Food:** Consumed by mages to maintain their strength. A food deficit will cause mages to be less effective in combat.
-   **Aura:** A mystical energy used for powerful spells and researching advanced technologies (future expansion).

## 6. Infrastructure

Players can build and upgrade infrastructure on worlds they control. Each world has a limited number of building slots.

### Resource Generators

| Infrastructure      | Level 1 Cost (Metal) | Level 1 Output/min | Upgrade Cost (Metal) | Upgrade Output Bonus/min |
|---------------------|----------------------|--------------------|----------------------|--------------------------|
| **Water Well**      | 50                   | 10                 | +75/lvl              | +10/lvl                  |
| **Mine**            | 50                   | 10                 | +75/lvl              | +10/lvl                  |
| **Farm**            | 50 (Requires 5 Water)| 10                 | +75/lvl              | +10/lvl                  |
| **Aura Ritual Site**| 100                  | 5                  | +150/lvl             | +5/lvl                   |

*Max level for all is 5.*

### Utility Buildings

| Infrastructure | Level 1 Cost (Metal) | Effect                                       | Upgrade Cost (Metal) | Upgrade Effect                               |
|----------------|----------------------|----------------------------------------------|----------------------|----------------------------------------------|
| **Mage Tower** | 150                  | Allows training of mages. Max 5 mages.       | +200/lvl             | +5 max mages/lvl. Unlocks new mage types.    |
| **Scrying Pool**| 100                  | Reveals stats of adjacent neutral worlds.    | +150/lvl             | Reveals stats of worlds 2 hops away, etc.    |

## 7. Combat

### Mages

-   Mages are the player's only combat unit.
-   They are trained at a Mage Tower.
-   They consume food. If food runs out, their combat effectiveness is halved.
-   Mages can be moved between connected worlds.

### Mage Types (Unlocked at Mage Tower Levels)

| Mage Type | Tower Level | Cost (Water, Aura) | Strengths/Weaknesses |
|-----------|-------------|--------------------|----------------------|
| **Water** | 1           | 20, 5              | Strong vs. Fire      |
| **Fire**  | 2           | 30, 10             | Strong vs. Earth     |
| **Earth** | 3           | 40, 15             | Strong vs. Water     |

## 8. UI/UX

### Main View

-   A 2D map showing worlds as circles and connections as lines.
-   Player-controlled worlds are colored blue, neutral are grey, and enemy (future) are red.

### HUD (Heads-Up Display)

-   Visible at all times at the top of the screen.
-   Displays current totals for Water, Metal, Food, and Aura.
-   Displays total number of mages and the food consumption rate.

### World Popup

-   Opened by tapping on a world.
-   Displays a dense grid of information:
    -   World Name & Type
    -   Resource Affinities
    -   List of infrastructure (with level)
    -   Available building slots
    -   Number of wild elementals present
    -   Buttons to build/upgrade infrastructure.
