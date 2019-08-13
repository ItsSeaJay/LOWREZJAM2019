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

export(Dictionary) var starting_items = {}
export(String) var starting_equipment = null

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
var direction_last
var velocity : Vector2
var speed : float
var terminal_velocity : float = self.walk_speed_normal
var reload_delta : float = 0.0
var equipment

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
	
	AudioSystem.play_music("res://items/tools/radio/enemy_radio_interference.ogg")
	
	if self.starting_items.size() > 0:
		var keys = self.starting_items.keys()
		
		for key in keys:
			var quantity = self.starting_items[key]
			
			self.inventory.insert_item(key, quantity)
	
	if self.starting_equipment.length() > 0:
		self.equip(Database.tables["items"][self.starting_equipment])

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
			
			if self.velocity == Vector2.ZERO:
				match(self.direction_last):
					Vector2.UP:
						self.sprite_body.play("idle_up")
						self.sprite_legs.play("idle_up")
					Vector2(-1.0, -1.0): # Up-left
						self.sprite_body.play("idle_up_left")
						self.sprite_legs.play("idle_up_left")
					Vector2(1.0, -1.0): # Up-right
						self.sprite_body.play("idle_up_right")
						self.sprite_legs.play("idle_up_right")
					Vector2.DOWN:
						self.sprite_body.play("idle_down")
						self.sprite_legs.play("idle_down")
					Vector2(-1.0, 1.0): # Down-left
						self.sprite_body.play("idle_down_left")
						self.sprite_legs.play("idle_down_left")
					Vector2(1.0, 1.0): # Down-right
						self.sprite_body.play("idle_down_right")
						self.sprite_legs.play("idle_down_right")
					Vector2.LEFT:
						self.sprite_body.play("idle_left")
						self.sprite_legs.play("idle_left")
					Vector2.RIGHT:
						self.sprite_body.play("idle_right")
						self.sprite_legs.play("idle_right")
			else:
				match(self.direction):
					Vector2.UP:
						self.sprite_body.play("walk_up")
						self.sprite_legs.play("walk_up")
					Vector2(-1.0, -1.0): # Up-left
						self.sprite_body.play("walk_up_left")
						self.sprite_legs.play("walk_up_left")
					Vector2(1.0, -1.0): # Up-right
						self.sprite_body.play("walk_up_right")
						self.sprite_legs.play("walk_up_right")
					Vector2.DOWN:
						self.sprite_body.play("walk_down")
						self.sprite_legs.play("walk_down")
					Vector2(-1.0, 1.0): # Down-left
						self.sprite_body.play("walk_down_left")
						self.sprite_legs.play("walk_down_left")
					Vector2(1.0, 1.0): # Down-right
						self.sprite_body.play("walk_down_right")
						self.sprite_legs.play("walk_down_right")
					Vector2.LEFT:
						self.sprite_body.play("walk_left")
						self.sprite_legs.play("walk_left")
					Vector2.RIGHT:
						self.sprite_body.play("walk_right")
						self.sprite_legs.play("walk_right")
			
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
	
	self.direction_last = self.direction

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
						AudioSystem.play_sound_formless(
							self.equipment["sounds"]["dry_fire"],
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
	AudioSystem.play_sound_formless(
		equipment["sounds"]["attack"],
		rand_range(0.66, 1.0)
	)
	
	# Play an appropriate attack animation
	self.sprite_body.stop()
	self.sprite_body.frame = 0
	
	var looking = self.look_target.normalized()
	
	match(looking):
		Vector2.UP:
			self.sprite_body.play("equipment_handgun_fire_up")
		Vector2(-1.0, -1.0): # Up-left
			self.sprite_body.play("equipment_handgun_fire_up_left")
		Vector2(1.0, -1.0): # Up-right
			self.sprite_body.play("equipment_handgun_fire_up_right")
		Vector2.DOWN:
			self.sprite_body.play("equipment_handgun_fire_down")
		Vector2(-1.0, 1.0): # Down-left
			self.sprite_body.play("equipment_handgun_fire_down_left")
		Vector2(1.0, 1.0): # Down-right
			self.sprite_body.play("equipment_handgun_fire_down_right")
		Vector2.LEFT:
			self.sprite_body.play("equipment_handgun_fire_left")
		Vector2.RIGHT:
			self.sprite_body.play("equipment_handgun_fire_right")
	
	# If the attack hit something
	if result.size() > 0:
		var target = result["collider"]
		var damage = rand_range(equipment["damage"]["min"], equipment["damage"]["max"])
		
		if target is Enemy:
			target.damage(damage)

func reload():
	self.reload_delta = equipment["reload_time"]
	
	var ammo_remaining = self.inventory.items[self.equipment["ammo_type"]]
	
	if ammo_remaining >= self.equipment["clip_size"]:
		self.equipment["ammo"] = self.equipment["clip_size"]
	else:
		self.equipment["ammo"] = ammo_remaining
	
	self.inventory.remove_item(self.equipment["ammo_type"], self.equipment["clip_size"])
	
	AudioSystem.play_sound_formless(self.equipment["sounds"]["reload"])
	transition(State.Reloading)

func equip(item):
	assert(item != null)
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
			
			match(self.position.direction_to(self.position + self.look_target)):
				Vector2.UP:
					self.sprite_body.play("equipment_handgun_aim_up")
				Vector2(-1.0, -1.0): # Up-left
					self.sprite_body.play("equipment_handgun_aim_up_left")
				Vector2(1.0, -1.0): # Up-right
					self.sprite_body.play("equipment_handgun_aim_up_right")
				Vector2.DOWN:
					self.sprite_body.play("equipment_handgun_aim_down")
				Vector2(-1.0, 1.0): # Down-left
					self.sprite_body.play("equipment_handgun_aim_down_left")
				Vector2(1.0, 1.0): # Down-right
					self.sprite_body.play("equipment_handgun_aim_down_right")
				Vector2.LEFT:
					self.sprite_body.play("equipment_handgun_aim_left")
				Vector2.RIGHT:
					self.sprite_body.play("equipment_handgun_aim_right")
		State.Reloading:
			self.sprite_body.play("idle_down")
	
	self.state = state