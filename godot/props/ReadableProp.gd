extends Node

export(String, FILE, "*.json") var dialogue_file = "res://data/dialogues/example.json"
export(float) var reading_delay = 1.0

onready var area : Area2D = $Area2D
onready var dialogue_box = preload("res://interface/overlays/dialogue/DialogueBox.tscn")

var within_reach = false
var reading_delta = reading_delay

const Player = preload("res://characters/player/Player.gd")

func _ready():
	area.connect("body_entered", self, "_on_Area2D_body_entered")
	area.connect("body_exited", self, "_on_Area2D_body_exited")

func _process(delta):
	reading_delta = max(reading_delta - delta, 0.0)
	
	if self.within_reach and reading_delta == 0.0:
		if Input.is_action_just_pressed("move_interact"):
			reading_delta = reading_delay
			
			var instance = dialogue_box.instance()
			instance.set_text("Hello, World!")
			
			self.get_node("/root/Game/DialogueLayer").add_child(instance)

func _on_Area2D_body_entered(body):
	if body is Player:
		self.within_reach = true

func _on_Area2D_body_exited(body):
	if body is Player:
		self.within_reach = false