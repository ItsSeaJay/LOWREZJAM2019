extends Node

const Player = preload("res://characters/player/Player.gd")
const DialogueBox = preload("res://interface/overlays/dialogue/DialogueBox.gd")

export(String, FILE, "*.json") var json_file = "res://items/example/example.json"
export(int) var quantity = 1

onready var metadata = load_metadata(json_file)
onready var area = $Area2D
onready var dialogue_box = preload("res://interface/overlays/dialogue/DialogueBox.tscn")
onready var dialogue_layer = get_tree().root.get_node("/root/Game/DialogueLayer")

var within_reach = false

signal picked_up

func _ready():
	area.connect("body_entered", self, "_on_Area2D_body_entered")
	area.connect("body_exited", self, "_on_Area2D_body_exited")
	
	self.connect("picked_up", self, "_on_pick_up")

func _process(delta):	
	if self.within_reach and Input.is_action_just_pressed("move_interact"):
		self.pick_up(PlayerData.instance.inventory)

func _on_Area2D_body_entered(body):
	if body is Player:
		self.within_reach = true

func _on_Area2D_body_exited(body):
	if body is Player:
		self.within_reach = false

func _on_pick_up():
	var instance = self.dialogue_box.instance()
	
	if self.quantity > 1:
		instance.set_text("Got " + str(self.quantity) + " " + self.metadata["name"] + "s.")
	else:
		instance.set_text("Got " + self.metadata["name"] + ".")
	
	dialogue_layer.add_child(instance)
	
	self.queue_free()

func pick_up(inventory):
	inventory.insert_item(self.metadata, quantity)
	emit_signal("picked_up")

func load_metadata(path):
	var items = {}
	
	var file = File.new()
	
	assert(file.file_exists(path))
	
	file.open(path, file.READ)
	
	var json = JSON.parse(file.get_as_text())
	
	file.close()
	
	return json.result