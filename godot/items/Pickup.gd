extends Node

const Player = preload("res://characters/player/Player.gd")
const DialogueBox = preload("res://interface/overlays/dialogue/DialogueBox.gd")

export(String) var key = "example"
export(int) var quantity = 1

onready var area = $Area2D
onready var dialogue_box = preload("res://interface/overlays/dialogue/DialogueBox.tscn")
onready var dialogue_layer = get_tree().root.get_node("/root/InterfaceLayer")

var within_reach = false

signal picked_up

func _ready():
	area.connect("body_entered", self, "_on_Area2D_body_entered")
	area.connect("body_exited", self, "_on_Area2D_body_exited")
	
	self.connect("picked_up", self, "_on_pick_up")
	
	get_tree().root.add_child(self.dialogue_layer)

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
	var name = Database.tables["items"][key]["name"]
	
	if self.quantity > 1:
		instance.set_text("Got " + str(self.quantity) + " " + name + "s.")
	else:
		instance.set_text("Got " + name + ".")
	
	dialogue_layer.add_child(instance)
	instance.animation_player.play("open")
	
	self.queue_free()

func pick_up(inventory):
	inventory.insert_item(self.key, quantity)
	emit_signal("picked_up")