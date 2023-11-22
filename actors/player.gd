extends CharacterBody2D

class_name Player

@export var gravity := 750
@export var run_speed := 150
@export var jump_speed := -300

enum PlayerState {IDLE, RUN, JUMP, HURT, DEAD}

var state := PlayerState.IDLE

signal life_changed
signal died

var life := 3: set = set_life

func set_life(value: int) -> void:
	life = value
	life_changed.emit(life)
	if life <= 0:
		change_state(PlayerState.DEAD)

func _ready() -> void:
	change_state(PlayerState.IDLE)
	
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	get_input()
	
	move_and_slide()
	
	if state == PlayerState.JUMP and is_on_floor():
		change_state(PlayerState.IDLE)
		
	if state == PlayerState.JUMP and velocity.y > 0:
		$AnimationPlayer.play("jump_down")
	
func change_state(new_state: PlayerState) -> void:
	state = new_state
	match state:
		PlayerState.IDLE:
			$AnimationPlayer.play("idle")
		PlayerState.RUN:
			$AnimationPlayer.play("run")
		PlayerState.HURT:
			$AnimationPlayer.play("hurt")
			velocity.y = -200
			velocity.x = -100 * sign(velocity.x)
			life -= 1
			await get_tree().create_timer(0.5).timeout
			change_state(PlayerState.IDLE)
		PlayerState.JUMP:
			$AnimationPlayer.play("jump_up")
		PlayerState.DEAD:
			died.emit()
			hide()

func get_input() -> void:
	if state == PlayerState.HURT:
		return
		
	var right := Input.is_action_pressed("right")
	var left := Input.is_action_pressed("left")
	var jump := Input.is_action_just_pressed("jump")
	
	# movement occurs in all states
	velocity.x = 0
	if right:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left:
		velocity.x -= run_speed
		$Sprite2D.flip_h = true
	# only allow jumping when on the ground
	if jump and is_on_floor():
		change_state(PlayerState.JUMP)
		velocity.y = jump_speed
	# IDLE transitions to RUN when moving
	if state == PlayerState.IDLE and velocity.x != 0:
		change_state(PlayerState.RUN)
	# RUN transitions to IDLE when standing still
	if state == PlayerState.RUN and velocity.x == 0:
		change_state(PlayerState.IDLE)
	# transtition to JUMP when in the air
	if state in [PlayerState.IDLE, PlayerState.RUN] and !is_on_floor():
		change_state(PlayerState.JUMP)

func reset(_position: Vector2):
	position = _position
	show()
	change_state(PlayerState.IDLE)
	life = 3

func hurt() -> void:
	if state != PlayerState.HURT:
		change_state(PlayerState.HURT)
