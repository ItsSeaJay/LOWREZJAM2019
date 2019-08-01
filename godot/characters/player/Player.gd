extends KinematicBody2D

class_name Player

export(int) var speed = 16.0

var velocity : Vector2

func _ready():
	if PlayerData.position != null:
		self.position = PlayerData.position

func _physics_process(delta):
	var direction = Vector2()
	
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	elif Input.is_action_pressed("move_down"):
		direction.y += 1
	
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	elif Input.is_action_pressed("move_right"):
		direction.x += 1
	
	velocity = move_and_slide(direction.normalized() * speed)