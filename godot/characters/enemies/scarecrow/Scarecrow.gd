extends "res://characters/enemies/Enemy.gd"

func _ready():
	self.connect("enemy_hurt", self, "_on_damage_taken")
	self.connect("enemy_killed", self, "_on_death")

func _on_damage_taken():
	Audio.play_sound(
		"res://characters/enemies/scarecrow/scarecrow_hurt.wav",
		self.position,
		rand_range(0.9, 1.0)
	)

func _on_death():
	Audio.play_sound(
		"res://characters/enemies/scarecrow/scarecrow_death.wav",
		self.position,
		rand_range(0.9, 1.0)
	)
	queue_free()