extends Node

const item_table_path = "res://data/equipment.json"
const Player = preload("res://characters/player/Player.gd")

export var tag = "unknown"
export var quantity = 1

onready var metadata = load_metadata()
onready var area = $Area2D

var within_reach = false

signal picked_up

func _ready():
	area.connect("body_entered", self, "_on_Area2D_body_entered")
	area.connect("body_exited", self, "_on_Area2D_body_exited")
	
	self.connect("picked_up", self, "_on_pick_up")

func _process(delta):	
	if self.within_reach and Input.is_action_just_pressed("move_interact"):
		self.pick_up(PlayerData.items)

func _on_Area2D_body_entered(body):
	if body is Player:
		self.within_reach = true

func _on_Area2D_body_exited(body):
	if body is Player:
		self.within_reach = false

func _on_pick_up():
	self.queue_free()

func pick_up(inventory):
	for item in range(quantity):
		inventory.append(self.metadata)
	
	emit_signal("picked_up")

func load_metadata():
	var items = {}
	
	var file = File.new()
	file.open(item_table_path, file.READ)
	
	var contents = file.get_as_text()
	var json = JSON.parse(contents)
	
	file.close()
	
	return json.result[tag]