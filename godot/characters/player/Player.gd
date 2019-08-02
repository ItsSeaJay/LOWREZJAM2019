extends KinematicBody2D

class_name Player

export(float) var terminal_velocity = 32.0
export(float) var acceleration = 1.0
export(float) var friction = 1.0

var health : int = 100
var velocity : Vector2
var speed : float

enum State {
	Normal
}
var state = State.Normal

func _ready():
	if PlayerData.position != null: self.position = PlayerData.position

func _physics_process(delta):
	match(state):
		State.Normal:
			handle_movement()

func handle_movement():
	var direction = Vector2.ZERO
	
	# Vertical
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	elif Input.is_action_pressed("move_down"):
		direction.y += 1
	
	# Horizontal
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	elif Input.is_action_pressed("move_right"):
		direction.x += 1
	
	# Vary the speed based on how long the player has been moving
	if direction != Vector2.ZERO:
		speed = min(terminal_velocity, speed + acceleration)
	else:
		speed = max(0.0, speed - friction)
	
	# Apply the speed in the current direction and move the player character
	velocity = move_and_slide(direction.normalized() * speed)