extends KinematicBody2D

class_name Player

export(float) var walk_speed_normal = 32.0
export(float) var walk_speed_aiming = 16.0
export(float) var walk_acceleration = 1.0
export(float) var walk_friction = 1.0
export(Dictionary) var walk_footstep_sounds = {
	"snow": [
		"res://characters/player/footsteps/snow/FootstepsSnowJP-001.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-002.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-003.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-004.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-005.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-006.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-007.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-008.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-010.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-011.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-012.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-013.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-014.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-015.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-016.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-017.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-018.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-019.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-020.wav",
		"res://characters/player/footsteps/snow/FootstepsSnowJP-021.wav"
	]
}
export(float) var walk_footstep_time = 0.5
onready var walk_footstep_delta = walk_footstep_time

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

onready var bullet_trail = preload("res://effects/bullet_trail/BulletTrail.tscn")
onready var muzzle_flash = preload("res://lights/muzzle_flash/MuzzleFlash.tscn")

const Enemy = preload("res://characters/enemies/Enemy.gd")

onready var vulnerable : bool = true

var health : int = self.health_max

var direction : Vector2
var direction_last : Vector2
var velocity : Vector2
var speed : float
var terminal_velocity : float = self.walk_speed_normal

var reload_delta : float = 0.0
var equipment

onready var audio_radio : AudioStreamPlayer = AudioSystem.play_music(
	"res://items/tools/radio/enemy_radio_interferance.ogg",
	Node.PAUSE_MODE_PROCESS
)
onready var audio_heartbeat : AudioStreamPlayer = AudioSystem.play_music(
	"res://characters/player/heartbeat.wav",
	Node.PAUSE_MODE_PROCESS
)

enum State {
	Normal,
	Aiming,
	Reloading
}
var state = State.Normal

signal health_changed
signal died

func _ready():
	self.handle_persistant_data()
	
	if self.starting_items.size() > 0:
		var keys = self.starting_items.keys()
		
		for key in keys:
			var quantity = self.starting_items[key]
			
			self.inventory.insert_item(key, quantity)
	
	if self.starting_equipment != null:
		self.equip(Database.tables["items"][self.starting_equipment])
	
	self.connect("died", self, "_on_death")
	inventory.connect("item_inserted", self, "_on_Inventory_item_inserted")

func _process(delta):
	# Allow the inventory screen to be opened by the player when the game isn't paused elsewhere
	if Input.is_action_just_pressed("ui_cancel") and not inventory.animation_player.is_playing():
		get_tree().paused = true
		
		inventory.animation_player.play("open")
	
	if self.inventory.items.has("tool_radio"):
		if self.get_enemy_count(get_tree().root) > 0:
			self.audio_radio.volume_db = 0.0
		else:
			self.audio_radio.volume_db = -80.0
	
	if self.health <= self.health_max / 2:
		self.audio_heartbeat.volume_db = 0.0
	else:
		self.audio_heartbeat.volume_db = -80.0
	
	if self.velocity != Vector2.ZERO:
		self.walk_footstep_delta = max(self.walk_footstep_delta - delta, 0.0)
		
		if self.walk_footstep_delta == 0.0:
			AudioSystem.play_music(
				self.walk_footstep_sounds["snow"][int(rand_range(0, self.walk_footstep_sounds["snow"].size()))],
				rand_range(0.8, 1.2)
			)
			self.walk_footstep_delta = self.walk_footstep_time
	else:
		self.walk_footstep_delta = 0.0

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

func _on_Inventory_item_inserted():
	PlayerData.target_items = self.inventory.items

func handle_persistant_data():
	PlayerData.instance = self
	
	if PlayerData.target_health != null:
		self.health = PlayerData.target_health
	
	if PlayerData.target_items != null:
		self.inventory.items = PlayerData.target_items
	
	if PlayerData.target_position != null:
		self.position = PlayerData.target_position

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
	self.audio_heartbeat.stop()
	self.audio_radio.stop()

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
	# First, figure out where the player is looking
	var looking = self.look_target.normalized()
	
	# Figure out what this attack will collide with in the sceen
	var space_state : Physics2DDirectSpaceState = get_world_2d().direct_space_state
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
	
	# Add a bullet trail that shows where the projectile went
	var bullet_trail_instance : Line2D = self.bullet_trail.instance()
	bullet_trail_instance.add_point(
		Vector2(round(self.position.x), round(self.position.y))
	)
	
	# Show a muzzle flash
	var muzzle_flash_instance : Node2D = self.muzzle_flash.instance()
	muzzle_flash_instance.position = self.position + (looking * 4)
	get_tree().root.add_child(muzzle_flash_instance)
	
	# Play an appropriate attack animation
	self.sprite_body.stop()
	self.sprite_body.frame = 0
	
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
		
		bullet_trail_instance.add_point(
			Vector2(round(target.position.x), round(target.position.y))
		)
		
		if target is Enemy:
			target.damage(damage)
	else:
		bullet_trail_instance.add_point(
			Vector2(round(self.position.x), round(self.position.y)) + (looking * equipment["range"])
		)
	
	# Add the bullet trail into the scene
	get_tree().root.add_child(bullet_trail_instance)

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
		self.health = max(self.health - amount, 0)
		
		if self.health > 0:
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

func get_enemy_count(start):
	var enemy_count = 0
	
	for node in start.get_children():
		if node is Enemy:
			enemy_count += 1
		
		if node.get_child_count() > 0:
			enemy_count += get_enemy_count(node)
	
	return enemy_count