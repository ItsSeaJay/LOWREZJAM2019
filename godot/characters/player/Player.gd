extends KinematicBody2D

class_name Player

export(float) var terminal_velocity = 32.0
export(float) var acceleration = 1.0
export(float) var friction = 1.0

export(float) var look_distance = 8.0
export(float) var look_weight = 0.4
var look_target : Vector2

onready var camera = $Camera2D

onready var inventory = $Interface/Inventory
onready var equipment = inventory.items[0]

const Enemy = preload("res://characters/enemies/Enemy.gd")

var health : int = 100
var velocity : Vector2
var speed : float

enum State {
	Normal,
	Aiming
}
var state = State.Normal

signal health_changed

func _ready():
	if PlayerData.position != null:
		self.position = PlayerData.position
	
	if PlayerData.health != null:
		self.health = PlayerData.health

func _physics_process(delta):
	match(self.state):
		State.Normal:
			handle_movement()
			handle_look_target()
			handle_camera_movement()
			
			if equipment != null:
				if Input.is_action_just_pressed("combat_aim"):
					state = State.Aiming
		State.Aiming:
			handle_movement()
			handle_camera_movement()
			
			if Input.is_action_just_released("combat_aim"):
				state = State.Normal
			
			if equipment != null:
				handle_attacking()

func handle_movement():
	var direction = Vector2.ZERO
	
	# Vertical
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	elif Input.is_action_pressed("move_down"):
		direction.y += 1
	
	# Horizontal
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	elif Input.is_action_pressed("move_right"):
		direction.x += 1
	
	# Vary the speed based on how long the player has been moving
	if direction != Vector2.ZERO:
		speed = min(terminal_velocity, speed + acceleration)
	else:
		speed = max(0.0, speed - friction)
	
	# Apply the speed in the current direction and move the player character
	velocity = move_and_slide(direction.normalized() * speed)

func handle_look_target():
	self.look_target.x = lerp(self.look_target.x, self.velocity.normalized().x * self.look_distance, self.look_weight)
	self.look_target.y = lerp(self.look_target.y, self.velocity.normalized().y * self.look_distance, self.look_weight)

func handle_camera_movement():
	self.camera.offset = self.look_target

func handle_attacking():
	if Input.is_action_just_pressed("combat_attack"):
		attack()

func attack():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(
		self.position, # Origin
		self.position + (self.look_target * equipment["range"]), # Target destination
		# Collision exceptions list
		[
			self
		]
	)
	
	# If the attack hit
	if result.size() > 0:
		var enemy = result["collider"] as Enemy
		enemy.damage(33.34)

func transition(state):
	match state:
		State.Normal:
			pass
		State.Aiming:
			pass
	
	self.state = state