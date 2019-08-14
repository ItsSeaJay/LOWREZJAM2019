extends "res://characters/enemies/Enemy.gd"

export var movement_speed = 16.0
export var vision_radius = 24.0
export var attack_distance = 12.0
export var attack_speed = 1.0
export(Vector2) var pause_time = Vector2(0.0, 1.0)
export(Vector2) var move_time = Vector2(0.0, 1.0)
export(float) var alert_time = 1.0
export(Vector2) var attack_damage = Vector2(25, 33)

var movement_direction = Vector2.ZERO

var timer_pause = rand_range(pause_time.x, pause_time.y)
var timer_move = rand_range(move_time.x, move_time.y)
var timer_alert = 0.0
var timer_attack = 0.0

enum State {
	Normal,
	Moving,
	Alert,
	Attacking
}
var state = State.Normal

func _ready():
	assert(pause_time.x <= pause_time.y)
	assert(move_time.x <= move_time.y)
	assert(attack_distance < vision_radius)
	assert(attack_damage.x <= attack_damage.y)
	
	self.connect("enemy_hurt", self, "_on_EnemyZombie_hurt")
	self.connect("enemy_killed", self, "_on_EnemyZombie_killed")

func _physics_process(delta):
	match(self.state):
		State.Normal:
			timer_pause = max(timer_pause - delta, 0.0)
			
			if self.position.distance_to(PlayerData.instance.position) < vision_radius:
				transition(State.Alert)
			
			if timer_pause == 0.0:
				transition(State.Moving)
		State.Moving:
			timer_move = max(timer_move - delta, 0.0)
			
			self.move_and_slide(self.movement_direction * self.movement_speed)
			
			if self.position.distance_to(PlayerData.instance.position) < vision_radius:
				transition(State.Alert)
			
			if timer_move == 0.0:
				transition(State.Normal)
		State.Alert:
			self.timer_alert = max(self.timer_alert - delta, 0.0)
			
			self.movement_direction = self.position.direction_to(PlayerData.instance.position)
			self.move_and_slide(self.movement_direction * self.movement_speed)
			
			var distance_to_player = self.position.distance_to(PlayerData.instance.position)
			
			if distance_to_player <= attack_distance:
				transition(State.Attacking)
			
			if distance_to_player > vision_radius and timer_alert == 0.0:
				transition(State.Normal)
		State.Attacking:
			self.timer_attack = max(self.timer_attack, 0.0)
			
			if self.timer_attack == 0.0:
				PlayerData.instance.damage(int(rand_range(attack_damage.x, attack_damage.y)))
				self.timer_attack = attack_speed
			
			var distance_to_player = self.position.distance_to(PlayerData.instance.position)
			
			if distance_to_player > attack_distance:
				transition(State.Alert)

func _on_EnemyZombie_hurt():
	transition(State.Alert)

func _on_EnemyZombie_killed():
	self.queue_free()

func transition(state):
	match(state):
		State.Normal:
			self.timer_pause = rand_range(move_time.x, move_time.y)
		State.Moving:
			self.timer_move = rand_range(move_time.x, move_time.y)
			self.movement_direction = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
		State.Alert:
			self.timer_alert = self.alert_time
		State.Attacking:
			pass
	
	self.state = state