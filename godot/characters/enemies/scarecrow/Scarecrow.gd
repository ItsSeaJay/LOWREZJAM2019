extends "res://characters/enemies/Enemy.gd"

export var vision_radius = 24
export var movement_speed = 64

onready var visibility_notifier = $VisibilityNotifier2D

var player_seen = false

func _ready():
	self.connect("enemy_hurt", self, "_on_damage_taken")
	self.connect("enemy_killed", self, "_on_death")

func _physics_process(delta):
	var distance_to_player = self.position.distance_to(PlayerData.instance.position)
	
	if distance_to_player < vision_radius:
		self.player_seen = true
	
	var camera_current : Camera2D = PlayerData.instance.get_node("Camera2D") as Camera2D
	var is_on_screen = visibility_notifier.is_on_screen()
	
	if not is_on_screen and player_seen:
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