extends CharacterBody2D

enum PlayerState {
	IDLE,
	WALK,
	JUMP,
	DUCK
}

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var capsule: CapsuleShape2D = collision_shape.shape as CapsuleShape2D
@onready var anim: AnimatedSprite2D = $CollisionShape2D/AnimatedSprite2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

var state: PlayerState
var direction = 0
var jumps = 0
var max_jumps = 2


func _ready():
	go_to_idle()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:
		PlayerState.IDLE:
			idle_state()

		PlayerState.WALK:
			walk_state()

		PlayerState.JUMP:
			jump_state()

		PlayerState.DUCK:
			duck_state()

	move_and_slide()


func idle_state():
	velocity.x = 0
	direction = Input.get_axis("left", "right")

	if not is_on_floor():
		go_to_jump()
		return

	if Input.is_action_pressed("duck"):
		go_to_duck()
		return

	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		jumps += 1
		go_to_jump()
		return

	if direction != 0:
		go_to_walk()
		return


func walk_state():
	direction = Input.get_axis("left", "right")
	velocity.x = direction * SPEED

	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

	if not is_on_floor():
		go_to_jump()
		return

	if Input.is_action_pressed("duck"):
		go_to_idle()
		return

	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		jumps += 1
		go_to_jump()
		return

	if direction == 0:
		go_to_idle()
		return


func jump_state():
	direction = Input.get_axis("left", "right")
	velocity.x = direction * SPEED

	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

	if Input.is_action_just_pressed("jump") and jumps < max_jumps:
		velocity.y = JUMP_VELOCITY
		jumps += 1

	if is_on_floor():
		jumps = 0

		if direction != 0:
			go_to_walk()
			return

		go_to_idle()
		return


func duck_state():
	velocity.x = 0

	if not Input.is_action_pressed("duck"):
		capsule.radius = 7
		capsule.height = 20
		collision_shape.position.y = 0

		anim.scale.y = 1.0

		go_to_idle()
		return


func go_to_idle():
	state = PlayerState.IDLE
	anim.play("idle")


func go_to_walk():
	state = PlayerState.WALK
	anim.play("walk")


func go_to_jump():
	state = PlayerState.JUMP
	anim.play("jump")


func go_to_duck():
	state = PlayerState.DUCK
	anim.play("duck")

	velocity.x = 0

	capsule.radius = 5
	capsule.height = 10
	collision_shape.position.y = 5

	anim.scale.y = 0.6
