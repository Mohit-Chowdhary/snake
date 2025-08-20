# 3D Snake Maze Game (Godot 4)

I’m currently developing a 3D maze game in Godot 4, where the player navigates a procedurally generated maze while being chased by an AI-controlled snake. The project focuses on implementing realistic AI behavior, procedural generation, and 3D character control.

## Current Features

* **Procedural Maze Generation:** Randomly generated maze with walls and walkable paths.
* **Player Movement:** 3D character with smooth physics-based movement, jumping, and mouse look.
* **Snake AI (Work in Progress):**

  * Wanders randomly when the player is not nearby.
  * Detects the player using scent trails.
  * Uses pathfinding to chase the player efficiently.
* **Scent Map System:** Tracks player movements with diffusion and decay mechanics to guide the snake.

## Maze System

The maze in this project is procedurally generated using a depth-first search (DFS) algorithm with backtracking. The generation ensures that there is always a path from the player’s start position to any other walkable cell, while creating interesting layouts for exploration and AI navigation.

How it Works

* Grid Initialization:
* The maze is represented as a 2D array of boolean values, where true indicates a walkable cell and false is a wall. The outer boundaries are always walls.

* DFS Maze Generation:

* Starts at a random initial cell.

* Chooses a random neighbor two cells away that hasn’t been visited.

Marks the cell between the current and neighbor as walkable to “carve” a path.

Recursively moves to the neighbor, using a stack to backtrack when no unvisited neighbors exist.

Dead-End Reduction:
After generating the maze, some dead ends are optionally opened up to improve gameplay flow, giving the player more choices while navigating.

3D Construction:

Walkable paths are empty, while walls are represented with StaticBody3D and BoxMesh objects.

A floor is created to cover the entire maze area.

Walls and floor include proper collision shapes for the player and AI.

Integration with Game Systems:

Player and snake spawn positions are chosen from walkable cells.

The scent map overlays the maze grid for the AI to track the player.

Skills Demonstrated

Procedural content generation (DFS algorithm, dead-end handling)

Grid-based 3D world construction (mesh instancing, collision setup)

Integration with AI pathfinding and game logic

## Work in Progress

* Improving the snake AI for more strategic chasing and pathfinding behavior.
* Optimizing the scent diffusion algorithm for performance and realism.
* Adding more visual polish to the environment and snake movement.
* Implementing scoring, UI, and potential multiplayer or cooperative modes.

## Technologies & Skills Demonstrated

* Godot 4 (GDScript, 3D physics, scene management)
* AI Programming (State machines, pathfinding, scent-based tracking)
* Procedural Generation (Maze algorithms)
* 3D Game Mechanics (Character control, collisions, camera handling)

## How to Run

1. Clone the repository:
   `git clone https://github.com/<your-username>/<repo-name>.git`
2. Open the project in Godot 4.
3. Run `Main.tscn` to start the game.


<img width="1907" height="996" alt="two" src="https://github.com/user-attachments/assets/4f51a301-7695-47d2-af1c-71fff6c11e46" />
<img width="1918" height="1007" alt="one" src="https://github.com/user-attachments/assets/12a5fbe8-065a-475a-b978-303425adfe50" />

---
