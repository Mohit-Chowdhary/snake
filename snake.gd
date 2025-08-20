extends CharacterBody3D

# ----------------- Variables -----------------
@export var speed: float = 3.0
@export var sight_range: float = 8.0
@export var cell_size: float = 2.0

@onready var player_ref: Node3D = get_node("/root/Main/player")

var direction: Vector3 = Vector3.ZERO
var wander_timer: float = 0.0
var wander_interval: float = 2.0  # seconds

# ----------------- Lifecycle -----------------
func _ready() -> void:
	randomize()
	pick_random_direction()

func _physics_process(delta: float) -> void:
	# Simple wandering logic
	wander_timer -= delta
	if wander_timer <= 0.0:
		pick_random_direction()
		wander_timer = wander_interval

	# If player is near, move towards them
	if global_position.distance_to(player_ref.global_position) < sight_range:
		direction = (player_ref.global_position - global_position).normalized()

	# Apply movement
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Gravity
	if not is_on_floor():
		velocity.y -= 30.0 * delta
	else:
		velocity.y = 0.0

	move_and_slide()

# ----------------- Helpers -----------------
func pick_random_direction() -> void:
	var angle = randf() * PI * 2.0
	direction = Vector3(cos(angle), 0, sin(angle)).normalized()
