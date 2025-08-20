extends Node3D

@export var maze_width := 50
@export var maze_height := 50
@export var cell_size := 2.0
@export var wall_height := 2.0

var maze = []
var scent_map = []


func _ready():
	randomize()
	generate_maze()
	init_scent_map()
	build_maze()
	spawn_floor()
	spawn_player()
	spawn_snake()


func generate_maze():
	# Initialize all cells as walls
	maze.resize(maze_height)
	for y in range(maze_height):
		maze[y] = []
		for x in range(maze_width):
			maze[y].append(false)

	# Make maze dimensions odd (ensure outer boundary is wall)
	if maze_width % 2 == 0:
		maze_width -= 1
	if maze_height % 2 == 0:
		maze_height -= 1

	var stack = []
	var start = Vector2i(1, 1)
	stack.append(start)
	maze[start.y][start.x] = true

	while stack.size() > 0:
		var current = stack.back()
		var neighbors = []

		for dir in [Vector2i(0, -2), Vector2i(0, 2), Vector2i(-2, 0), Vector2i(2, 0)]:
			var next = current + dir
			if next.x > 0 and next.x < maze_width - 1 and next.y > 0 and next.y < maze_height - 1:
				if !maze[next.y][next.x]:
					neighbors.append(dir)

		if neighbors.size() > 0:
			var chosen = neighbors[randi() % neighbors.size()]
			var between = current + chosen / 2
			var next = current + chosen

			maze[between.y][between.x] = true
			maze[next.y][next.x] = true
			stack.append(next)
		else:
			stack.pop_back()

	fix_all_dead_ends()  # removes some dead ends for better flow


func fix_all_dead_ends():
	var changed = true
	while changed:
		changed = false
		for y in range(1, maze_height - 1):
			for x in range(1, maze_width - 1):
				if !maze[y][x]:
					continue

				var exits = []
				for dir in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
					var n = Vector2i(x, y) + dir
					if n.x > 0 and n.x < maze_width - 1 and n.y > 0 and n.y < maze_height - 1:
						if maze[n.y][n.x]:
							exits.append(n)

				# It's a dead end if only 1 exit
				if exits.size() == 1:
					# Try to open up one more direction (not the exit)
					var possible_dirs = []
					for dir in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
						var n = Vector2i(x, y) + dir
						if n.x > 0 and n.x < maze_width - 1 and n.y > 0 and n.y < maze_height - 1:
							if !maze[n.y][n.x]:
								possible_dirs.append(n)

					if possible_dirs.size() > 0:
						var open_dir = possible_dirs[randi() % possible_dirs.size()]
						maze[open_dir.y][open_dir.x] = true
						changed = true


func build_maze():
	for y in range(maze_height):
		for x in range(maze_width):
			if !maze[y][x]:
				spawn_wall(Vector3(x * cell_size, wall_height / 2, y * cell_size))


func spawn_floor():
	var floor_body = StaticBody3D.new()

	# Visual
	var mesh = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()

	var floor_width = maze_width * cell_size
	var floor_depth = maze_height * cell_size
	var floor_thickness = 0.5

	mesh.scale = Vector3(floor_width, floor_thickness, floor_depth)
	mesh.position = Vector3.ZERO

	# Material (optional)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.2, 0.2)
	mesh.material_override = mat
	floor_body.add_child(mesh)

	# Collision
	var collider = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = mesh.scale
	collider.shape = shape
	collider.position = Vector3.ZERO
	floor_body.add_child(collider)

	# Position whole floor in world
	floor_body.position = Vector3(
		floor_width / 2 - cell_size / 2,
		-floor_thickness / 2,
		floor_depth / 2 - cell_size / 2
	)

	add_child(floor_body)



func spawn_wall(pos: Vector3):
	var wall_body = StaticBody3D.new()

	# Visual mesh
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	mesh_instance.scale = Vector3(cell_size, wall_height, cell_size)
	mesh_instance.position = Vector3.ZERO

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.1, 0.1)
	mesh_instance.material_override = mat
	wall_body.add_child(mesh_instance)

	# Collision shape
	var collider = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = mesh_instance.scale
	collider.shape = shape
	collider.position = Vector3.ZERO
	wall_body.add_child(collider)

	# Position wall in world
	wall_body.position = pos
	add_child(wall_body)

func spawn_player():
	var valid_positions = []
	for y in range(1, maze_height - 1):
		for x in range(1, maze_width - 1):
			if maze[y][x]:  # walkable cell
				valid_positions.append(Vector3(x * cell_size, 1.0, y * cell_size))

	if valid_positions.size() > 0:
		var spawn_pos = valid_positions[randi() % valid_positions.size()]
		
		# Assuming your player is already in scene
		var player = get_node("/root/Main/player")  # 🔁 adjust this path
		player.global_position = spawn_pos

func spawn_snake():
	var valid_positions = []
	for y in range(1, maze_height - 1):
		for x in range(1, maze_width - 1):
			if maze[y][x]:
				valid_positions.append(Vector3(x * cell_size, 1.0, y * cell_size))

	if valid_positions.size() > 0:
		var spawn_pos = valid_positions[randi() % valid_positions.size()]
		var snake_scene = preload("res://Snake.tscn")  # use your actual Snake scene path
		var snake = snake_scene.instantiate()
		snake.name = "Snake"
		add_child(snake)
		snake.global_position = spawn_pos

		snake.global_position = spawn_pos


func init_scent_map():
	scent_map.resize(maze_height)
	for y in range(maze_height):
		scent_map[y] = []
		for x in range(maze_width):
			scent_map[y].append(0.0)

func update_scent_map(delta):
	var player = get_node("/root/Main/player")
	var cell = world_to_cell(player.global_position)
	scent_map[cell.y][cell.x] += delta * 10.0  # deposit scent

	# Simple diffusion
	for y in range(1, maze_height - 1):
		for x in range(1, maze_width - 1):
			var avg = (
				scent_map[y-1][x] + scent_map[y+1][x] +
				scent_map[y][x-1] + scent_map[y][x+1]
		 ) / 4.0
			scent_map[y][x] = lerp(scent_map[y][x], avg, 0.1)

	# Decay over time
	for y in range(maze_height):
		for x in range(maze_width):
			scent_map[y][x] *= pow(0.98, delta * 60.0)

func world_to_cell(pos: Vector3) -> Vector2i:
	return Vector2i(
		int(pos.x / cell_size),
		int(pos.z / cell_size)
	)

func _physics_process(delta):
	update_scent_map(delta)
