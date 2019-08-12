extends KinematicBody2D

class_name Player

export(float) var walk_speed_normal = 32.0
export(float) var walk_speed_aiming = 16.0
export(float) var walk_acceleration = 1.0
export(float) var walk_friction = 1.0

export(float) var look_distance = 8.0
export(float) var look_weight = 0.4
var look_target : Vector2

export(int) var health_max = 100

onready var camera = $Camera2D

onready var inventory = $Interface/Inventory
onready var equipment_display = $Interface/Inventory/MarginContainer/PanelContainer/VBoxContainer/PrimaryContainer/LeftContainer/EquipmentDisplay
onready var no_equipment_icon = "res://items/equipment/none/none_icon.png"

onready var sprite_body : AnimatedSprite = $Sprites/Body
onready var sprite_legs : AnimatedSprite = $Sprites/Legs

const Enemy = preload("res://characters/enemies/Enemy.gd")

onready var vulnerable : bool = true
var health : int = self.health_max
var direction : Vector2
var velocity : Vector2
var speed : float
var terminal_velocity : float = self.walk_speed_normal
var equipment
var reload_delta : float = 0.0

enum State {
	Normal,
	Aiming,
	Reloading
}
var state = State.Normal

signal health_changed
signal died

func _ready():
	PlayerData.instance = self
	
	self.connect("died", self, "_on_death")

func _process(delta):
	# Allow the inventory screen to be opened by the player when the game isn't paused elsewhere
	if Input.is_action_just_pressed("ui_cancel") and not inventory.animation_player.is_playing():
		get_tree().paused = true
		
		inventory.animation_player.play("open")

func _physics_process(delta):
	match(self.state):
		State.Normal:
			handle_movement()
			handle_look_target()
			handle_camera_movement()
			
			if equipment != null:
				if Input.is_action_pressed("combat_aim"):
					if self.velocity.normalized() != Vector2.ZERO:
						transition(State.Aiming)
		State.Aiming:
			handle_movement()
			handle_camera_movement()
			
			self.equipment["heat"] = max(self.equipment["heat"] - delta, 0.0)
			
			if not Input.is_action_pressed("combat_aim"):
				transition(State.Normal)
			
			if equipment != null:
				handle_attacking()
		State.Reloading:
			self.reload_delta = max(self.reload_delta - delta, 0.0)
			
			if self.reload_delta == 0.0:
				transition(State.Aiming)

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
		self.speed = min(self.terminal_velocity, self.speed + self.walk_acceleration)
	else:
		self.speed = max(0.0, self.speed - self.walk_friction)
	
	# Apply the speed in the current direction and move the player character
	self.velocity = move_and_slide(self.direction.normalized() * self.speed)

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
				if equipment["ammo"] > 0:
					attack()
					equipment["heat"] = equipment["cooldown"]
				else:
					if self.inventory.items.has(self.equipment["ammo_type"]):
						self.reload()
					else:
						# Give the player some feedback that they are out of ammo
						AudioSystem.play_sound(
							self.equipment["sounds"]["dry_fire"],
							self.position + self.camera.offset,
							rand_range(0.8, 1.0)
						)
						# Ensure that the sound doesn't repeat too often
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
	
	# Reduce the the ammount of ammo in the clip
	equipment["ammo"] -= 1
	
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

func reload():
	self.reload_delta = equipment["reload_time"]
	
	var ammo_remaining = self.inventory.items[self.equipment["ammo_type"]]
	
	if ammo_remaining >= self.equipment["clip_size"]:
		self.equipment["ammo"] = self.equipment["clip_size"]
	else:
		self.equipment["ammo"] = ammo_remaining
	
	self.inventory.remove_item(self.equipment["ammo_type"], self.equipment["clip_size"])
	
	AudioSystem.play_sound(
		self.equipment["sounds"]["reload"],
		self.position + self.camera.offset,
		rand_range(0.9, 1.0)
	)
	transition(State.Reloading)

func equip(item):
	if item != null:
		self.equipment = item
		self.equipment_display.get_node("TextureRect").set_texture(load(item["icon"]))

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
			self.terminal_velocity = self.walk_speed_normal
		State.Aiming:
			self.terminal_velocity = self.walk_speed_aiming
	
	self.state = state