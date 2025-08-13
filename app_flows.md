
# Elemental Conquest App Flows

## 1. New Game Flow

1.  **User** opens the app.
2.  **System** displays `MainMenuScreen`.
3.  **User** taps `NewGameButton`.
4.  **System** initializes a new `GameController` with a starting world.
5.  **System** navigates to `MainGameScreen`.
6.  **System** starts the game loop (ticks).

## 2. World Interaction Flow

1.  **User** is on the `MainGameScreen`.
2.  **User** taps on a world (circle) on the `WorldMapWidget`.
3.  **System** displays a `WorldPopupWidget` with the details of the selected world.
4.  **User** can view information about the world.

## 3. Building Infrastructure Flow

1.  **User** has a `WorldPopupWidget` open.
2.  **User** taps the "Build" button for a specific infrastructure type (e.g., "Build Mine").
3.  **System** checks if the player has enough resources (`Metal`).
4.  **If** the player has enough resources:
    -   **System** deducts the resource cost.
    -   **System** creates the new infrastructure on the world.
    -   **System** updates the `WorldPopupWidget` to show the new building.
5.  **Else**:
    -   **System** shows an error message (e.g., "Not enough metal").

## 4. Upgrading Infrastructure Flow

1.  **User** has a `WorldPopupWidget` open.
2.  **User** taps the "Upgrade" button next to an existing piece of infrastructure.
3.  **System** checks if the player has enough resources and if the building is not at max level.
4.  **If** the conditions are met:
    -   **System** deducts the resource cost.
    -   **System** increases the level of the infrastructure.
    -   **System** updates the `WorldPopupWidget`.
5.  **Else**:
    -   **System** shows an error message.

## 5. Training Mages Flow

1.  **User** opens the `WorldPopupWidget` for a world with a `Mage Tower`.
2.  **User** taps the "Train Mage" button.
3.  **System** checks for required resources (`Water`, `Aura`) and available capacity in the `Mage Tower`.
4.  **If** successful:
    -   **System** deducts resources.
    -   **System** adds a new mage to the player's army.
    -   **System** updates the HUD.
5.  **Else**:
    -   **System** shows an error message.

## 6. Combat Flow

1.  **System** spawns `Wild Elementals` on a player-controlled world.
2.  **User** sees the elementals on the `WorldMapWidget`.
3.  **User** selects a world with mages and chooses to move them to the world with elementals.
4.  **System** moves the mages to the target world.
5.  **System** automatically resolves combat between mages and elementals based on their stats and types.
6.  **System** updates the UI to reflect the outcome (e.g., elementals disappear, infrastructure may be damaged).
