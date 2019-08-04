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
onready var equipment = null

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
	PlayerData.instance = self
	
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
				if Input.is_action_pressed("combat_aim"):
					if self.velocity.normalized() != Vector2.ZERO:
						self.state = State.Aiming
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
	self.look_target = self.velocity.normalized() * self.look_distance

func handle_camera_movement():
	self.camera.offset.x = lerp(self.camera.offset.x, self.look_target.x, self.look_weight)
	self.camera.offset.y = lerp(self.camera.offset.y, self.look_target.y, self.look_weight)

func handle_attacking():
	match equipment["transmission"]:
		"automatic":
			if Input.is_action_pressed("combat_attack") and equipment["heat"] == 0.0:
				attack()
				equipment["heat"] = equipment["cooldown"]
		"semi_automatic":
			if Input.is_action_just_pressed("combat_attack") and equipment["heat"] == 0.0:
				attack()
				equipment["heat"] = equipment["cooldown"]

func attack():
	# Figure out what this attack will collide with in the sceen
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(
		self.position, # Origin
		self.position + (self.look_target * equipment["range"]), # Target destination
		# Collision exceptions list
		[
			self
		]
	)
	
	# Give audio feedback that the player has attacked
	Audio.play_sound(
		equipment["sounds"]["attack"],
		self.position + self.camera.offset,
		rand_range(0.66, 1.0)
	)
	
	# If the attack hit
	if result.size() > 0:
		var enemy = result["collider"] as Enemy
		var damage = rand_range(equipment["damage"]["min"], equipment["damage"]["max"])
		enemy.damage(damage)

func transition(state):
	match state:
		State.Normal:
			pass
		State.Aiming:
			pass
	
	self.state = state