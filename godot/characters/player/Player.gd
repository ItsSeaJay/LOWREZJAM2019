extends KinematicBody2D

class_name Player

export(float) var walk_speed_normal = 32.0
export(float) var walk_speed_aiming = 24.0
export(float) var walk_acceleration = 1.0
export(float) var walk_friction = 1.0

export(float) var look_distance = 8.0
export(float) var look_weight = 0.4
var look_target : Vector2

export(int) var health_max = 100

onready var camera = $Camera2D

onready var inventory = $Interface/Inventory
onready var equipment = inventory.get_equipment()

const Enemy = preload("res://characters/enemies/Enemy.gd")

onready var vulnerable : bool = true
var health : int = self.health_max
var direction : Vector2
var velocity : Vector2
var speed : float
var terminal_velocity : float = self.walk_speed_normal

enum State {
	Normal,
	Aiming
}
var state = State.Normal

signal health_changed
signal died

func _ready():
	PlayerData.instance = self
	
	if PlayerData.position != null:
		self.position = PlayerData.position
	
	if PlayerData.health != null:
		self.health = PlayerData.health
	
	self.connect("died", self, "_on_death")

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
	self.direction = Vector2.ZERO
	
	# Vertical
	if Input.is_action_pressed("move_up"):
		self.direction.y -= 1
	elif Input.is_action_pressed("move_down"):
		self.direction.y += 1
	
	# Horizontal
	if Input.is_action_pressed("move_left"):
		self.direction.x -= 1
	elif Input.is_action_pressed("move_right"):
		self.direction.x += 1
	
	# Vary the speed based on how long the player has been moving
	if self.direction != Vector2.ZERO:
		speed = min(terminal_velocity, speed + walk_acceleration)
	else:
		speed = max(0.0, speed - walk_friction)
	
	# Apply the speed in the current direction and move the player character
	velocity = move_and_slide(direction.normalized() * speed)

func _on_death():
	SceneChanger.change_scene("res://interface/screens/game_over/GameOver.tscn")

func handle_look_target():
	self.look_target = self.direction * self.look_distance

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
	AudioSystem.play_sound(
		equipment["sounds"]["attack"],
		self.position + self.camera.offset,
		rand_range(0.66, 1.0)
	)
	
	# If the attack hit
	if result.size() > 0:
		var enemy = result["collider"] as Enemy
		var damage = rand_range(equipment["damage"]["min"], equipment["damage"]["max"])
		enemy.damage(damage)

func heal(amount):
	self.health = min(health + amount, health_max)
	self.emit_signal("health_changed")

func damage(amount):
	if vulnerable:
		self.health = max(health - amount, 0)
	
		if health > 0:
			self.emit_signal("health_changed")
		else:
			self.emit_signal("died")

func transition(state):
	match state:
		State.Normal:
			pass
		State.Aiming:
			self.terminal_velocity = self.walk_speed_normal
	
	self.state = state