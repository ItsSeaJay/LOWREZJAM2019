extends KinematicBody2D

class_name Player

export(int) var speed = 16.0
export(float) var camera_look_distance = 16.0
export(float) var camera_lerp_weight = 0.1

onready var camera = $Camera2D
onready var camera_look_target : Vector2 = self.position

var health = 100
var velocity : Vector2

func _ready():
	if PlayerData.position != null: self.position = PlayerData.position

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
	
	# Change the direction of the camera
	if not Input.is_action_pressed("combat_aim"):
		camera_look_target = direction * camera_look_distance
	
	camera.offset = Vector2(
		lerp(camera.offset.x, camera_look_target.x, camera_lerp_weight),
		lerp(camera.offset.y, camera_look_target.y, camera_lerp_weight)
	)
	velocity = move_and_slide(direction.normalized() * speed)