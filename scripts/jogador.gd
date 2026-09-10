extends CharacterBody2D


enum PlayerState {
	IDLE,
	WALK,
	JUMP,
	HURT,
	ATTACK
}


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_golpe: Area2D = $AreaGolpe


const SPEED = 200.0
const JUMP_VELOCITY = -300.0


@export var vida_maxima: int = 5
@export var tempo_hurt: float = 0.4

@export var dano_do_golpe: int = 2
@export var quadro_do_golpe: int = 3


var vida: int
var tempo_no_hurt: float = 0.0

var state: PlayerState
var direction = 0
var jumps = 0
var max_jumps = 2

var golpe_aplicado: bool = false


func _ready():
	vida = vida_maxima
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

		PlayerState.HURT:
			hurt_state()

		PlayerState.ATTACK:
			attack_state()

	move_and_slide()


# =========================
# IDLE
# =========================

func idle_state():
	velocity.x = 0
	direction = Input.get_axis("left", "right")

	if not is_on_floor():
		go_to_jump()
		return

	if Input.is_action_just_pressed("attack"):
		go_to_attack()
		return

	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		jumps += 1
		go_to_jump()
		return

	if direction != 0:
		go_to_walk()
		return


func go_to_idle():
	state = PlayerState.IDLE
	anim.play("idle")
	anim.modulate = Color(1, 1, 1)


# =========================
# WALK
# =========================

func walk_state():
	direction = Input.get_axis("left", "right")
	velocity.x = direction * SPEED

	if direction < 0:
		anim.flip_h = true
		area_golpe.position.x = -abs(area_golpe.position.x)

	elif direction > 0:
		anim.flip_h = false
		area_golpe.position.x = abs(area_golpe.position.x)

	if not is_on_floor():
		go_to_jump()
		return

	if Input.is_action_just_pressed("attack"):
		go_to_attack()
		return

	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		jumps += 1
		go_to_jump()
		return

	if direction == 0:
		go_to_idle()
		return


func go_to_walk():
	state = PlayerState.WALK
	anim.play("walk")


# =========================
# JUMP
# =========================

func jump_state():
	direction = Input.get_axis("left", "right")
	velocity.x = direction * SPEED

	if direction < 0:
		anim.flip_h = true
		area_golpe.position.x = -abs(area_golpe.position.x)

	elif direction > 0:
		anim.flip_h = false
		area_golpe.position.x = abs(area_golpe.position.x)

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


func go_to_jump():
	state = PlayerState.JUMP
	anim.play("jump")


# =========================
# DANO / HURT
# =========================

func levar_dano(quantidade: int) -> void:
	if state == PlayerState.HURT:
		return

	vida -= quantidade

	print("vida: ", vida)

	if vida <= 0:
		morrer()
		return

	go_to_hurt()


func go_to_hurt() -> void:
	state = PlayerState.HURT

	anim.play("hurt")

	tempo_no_hurt = 0.0
	velocity.x = 0

	anim.modulate = Color(1, 0.4, 0.4)

	# Se o jogador apanhar durante o ataque,
	# a área de golpe precisa ser desligada.
	area_golpe.monitoring = false


func hurt_state() -> void:
	tempo_no_hurt += get_physics_process_delta_time()

	if tempo_no_hurt >= tempo_hurt:
		go_to_idle()
		return


# =========================
# ATAQUE
# =========================

func go_to_attack() -> void:
	state = PlayerState.ATTACK

	anim.play("attack")

	velocity.x = 0

	golpe_aplicado = false

	area_golpe.monitoring = true


func attack_state() -> void:
	# O dano acontece somente no quadro do golpe.
	if not golpe_aplicado and anim.frame >= quadro_do_golpe:
		golpe_aplicado = true

		for corpo in area_golpe.get_overlapping_bodies():
			if corpo != self and corpo.has_method("levar_dano"):
				corpo.levar_dano(dano_do_golpe)

	# Quando a animação terminar, volta para parado.
	if not anim.is_playing():
		area_golpe.monitoring = false
		go_to_idle()
		return


# =========================
# MORTE
# =========================

func morrer() -> void:
	state = PlayerState.HURT

	anim.play("death")

	velocity.x = 0

	area_golpe.monitoring = false

	set_physics_process(false)
