extends CharacterBody2D

# From A Key(s) Path
# Movement exports
@export_group("Movement")
@export var max_speed:		float = 120.0 # Player max speed in px/s
@export var jump_height:	float = 40.0 # px
@export var gravity:		float = 310.0 # px/s/s
@export var gravity_strong:	float = 650.0 # px/s/s
@export var acceleration:	float = 512.0 # px/s/s
@export var deceleration:	float = 1024.0 # px/s/s
# Buffers
@export_group("Buffers")
@export var air_buffer = 0.1
@export var jump_buffer = 0.07

@onready var _Sprite = $Sprite
@onready var _Collision = $Collider
@onready var _AnimationTree: AnimationTree = $AnimationTree
@onready var _StateMachine: AnimationNodeStateMachinePlayback  = _AnimationTree["parameters/playback"]

# Provided values
var dir: float = 0.0
var jump: bool = false

var target_speed: float = 0.0
var target_accel: float = 0.0
var target_gravity: float = gravity_strong
var air_time = air_buffer
var jump_time = jump_buffer
var on_ground: bool = false

func _process(_delta):
	if target_speed < 0.0:
		_Sprite.flip_h = true
	elif target_speed > 0.0:
		_Sprite.flip_h = false

	# Animation states
	if on_ground:
		if target_speed != 0.0:
			_StateMachine.travel("run")
		else:
			_StateMachine.travel("idle")
	else:
		if velocity.y >= 0.0:
			_StateMachine.travel("fall")

func _physics_process(delta):
	# Get horizontal movement direction
	# Direction is provided by a Movement Provider -> either a Player or IA

	# Vertical movement
	if velocity.y > 0 or (not jump and jump_time < jump_buffer):
		target_gravity = gravity_strong
	velocity.y += target_gravity * delta
	# Horizontal movement
	target_speed = dir * max_speed
	target_accel = acceleration if dir and sign(dir) == sign(velocity.x) else deceleration
	velocity.x = move_toward(velocity.x, target_speed, target_accel * delta)

	# Apply velocity
	var collision = move_and_slide()
	var landed = is_on_floor() and not on_ground

	# Update buffers
	if jump:
		jump_time = 0.0 # Reset jump time
	on_ground = is_on_floor()
	if on_ground:
		air_time = 0.0 # Reset air time
	else:
		air_time = min(air_time + delta, air_buffer)
		jump_time = min(jump_time + delta, jump_buffer)

	# Apply jump / landing
	if jump_time < jump_buffer and air_time < air_buffer:
		do_jump()
	elif landed:
		do_land()

func do_jump()->void:
	# Movement variables
	velocity.y = -sqrt(jump_height * 2.0 * gravity)
	target_gravity = gravity

	# Status variables
	jump_time = jump_buffer
	air_time = air_buffer
	on_ground = false

	# Animation and effects
	_StateMachine.travel("jump")

func do_land()->void:
	pass
