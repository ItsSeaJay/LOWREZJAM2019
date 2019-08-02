extends "res://characters/enemies/Enemy.gd"

func _ready():
	self.connect("enemy_hurt", self, "_on_damage_taken")
	self.connect("enemy_killed", self, "_on_death")

func _on_damage_taken():
	print("hurt")

func _on_death():
	print("death")