extends "res://items/Pickup.gd"

onready var area2d = $Area2D

var tag = "handgun"
var within_reach = false

const Player = preload("res://characters/player/Player.gd")

func _ready():
	self.connect("picked_up", self, "_on_picked_up")
	area2d.connect("body_entered", self, "_on_Area2D_body_entered")
	area2d.connect("body_exited", self, "_on_Area2D_body_exited")

func _process(delta):
	if self.within_reach and Input.is_action_pressed("interact"):
		pick_up(Player.items)

func _on_Area2D_body_entered(body):
	print(body)
	
	if body is Player:
		self.within_reach = true

func _on_Area2D_body_exited(body):
	if body is Player:
		self.within_reach = false

func _on_picked_up():
	queue_free()