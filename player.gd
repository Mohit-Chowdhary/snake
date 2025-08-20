extends CharacterBody3D

@onready var camera = $Camera3D
@export var mouse_sensitivity := 0.002

@export var speed := 10.0
@export var acceleration := 10.0
@export var friction := 8.0
@export var gravity := 20.0
@export var jump_velocity := 15.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		# Yaw (left-right) → rotate the player body
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Pitch (up-down) → rotate the camera only
		camera.rotate_x(-event.relative.y * mouse_sensitivity)

		# Clamp pitch so camera can't flip upside down
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	# Optional: Escape to unlock mouse
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	input_dir = input_dir.normalized()
	
	var direction_global = (transform.basis * input_dir).normalized()
	var target_velocity = direction_global * speed
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# Allow jumping when on the ground
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	# Horizontal smoothing
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	# Apply friction when not moving
	if input_dir == Vector3.ZERO:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

	move_and_slide()
