extends KinematicBody2D

class_name Enemy

var health = 100

signal enemy_killed
signal enemy_hurt

func get_health():
	return health

func damage(amount):
	health = max(health - amount, 0)
	
	emit_signal("enemy_hurt")
	
	if health == 0:
		emit_signal("enemy_killed")