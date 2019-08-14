extends Node

export(String, FILE, "*.json") var dialogue_file = "res://data/dialogues/example.json"

onready var area : Area2D = $Area2D
onready var dialogue_box = preload("res://interface/overlays/dialogue/DialogueBox.tscn")

var within_reach = false

const Player = preload("res://characters/player/Player.gd")

func _ready():
	area.connect("body_entered", self, "_on_Area2D_body_entered")
	area.connect("body_exited", self, "_on_Area2D_body_exited")

func _process(delta):
	if self.within_reach:
		if Input.is_action_just_pressed("move_interact") and not get_tree().paused:
			var instance = dialogue_box.instance()
			instance.set_text("Hello, World!")
			
			self.get_node("/root/Game/DialogueLayer").add_child(instance)

func _on_Area2D_body_entered(body):
	if body is Player:
		self.within_reach = true

func _on_Area2D_body_exited(body):
	if body is Player:
		self.within_reach = false