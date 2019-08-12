extends "res://characters/enemies/Enemy.gd"

export var vision_radius = 24
export var movement_speed = 64
export var padding = 8

onready var visibility_notifier = $VisibilityNotifier2D

var player_seen = false

func _ready():
	self.connect("enemy_hurt", self, "_on_damage_taken")
	self.connect("enemy_killed", self, "_on_death")

func _physics_process(delta):
	var distance_to_player = self.position.distance_to(PlayerData.instance.position)
	
	if distance_to_player < vision_radius:
		self.player_seen = true
	
	if self.player_seen and not is_on_screen(visibility_notifier.rect.size.y) and distance_to_player:
		var direction = -((self.position - PlayerData.instance.position).normalized())
		var velocity = move_and_slide(direction * self.movement_speed)

func _on_damage_taken():
	AudioSystem.play_sound(
		"res://characters/enemies/scarecrow/scarecrow_hurt.wav",
		self.position,
		rand_range(0.9, 1.0)
	)

func _on_death():
	AudioSystem.play_sound(
		"res://characters/enemies/scarecrow/scarecrow_death.wav",
		self.position,
		rand_range(0.9, 1.0)
	)
	queue_free()

func is_on_screen(padding=0):
	# Do some calculations to figure out whether the scarecrow is visible to the player
	var camera : Camera2D = PlayerData.instance.get_node("Camera2D") as Camera2D
	var rect : Rect2 = visibility_notifier.rect
	rect.position += self.global_position
	var camera_rect = camera.get_viewport().get_visible_rect()
	
	# Add some optional padding to the camera rect
	camera_rect.size.x += padding
	camera_rect.size.y += padding
	
	# Rect2 has its origin in the top left
	# ...because of course it does.
	camera_rect.position += camera.global_position - (camera_rect.size / 2)
	var is_on_screen = rect.intersects(camera_rect)
	
	return is_on_screen