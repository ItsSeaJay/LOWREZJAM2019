extends Control

onready var item_listing = preload("res://interface/inventory/item/ItemListing.tscn")

onready var item_display = $ScrollContainer/VBoxContainer
onready var health_display = $MarginContainer/PanelContainer/VBoxContainer/PrimaryContainer/LeftContainer/HealthDisplay

onready var animation_player = $AnimationPlayer

onready var player = $"/root/Game/Characters/Player"

var items = []

signal item_inserted

func _ready():
	self.connect("item_inserted", self, "_on_item_inserted")
	player.connect("health_changed", self, "_on_Player_health_changed")
	
	for item in items:
		var instance = item_listing.instance()
		var label_name = instance.get_node("Name")
		label_name.text = item["name"]
		
		self.item_display.add_child(instance)

func _process(delta):
	# Allow the inventory screen to be opened and closed
	if Input.is_action_just_pressed("ui_cancel") and not animation_player.is_playing():
		get_tree().paused = not get_tree().paused
		
		if not self.visible:
			animation_player.play("open")
		else:
			animation_player.play("close")

func _on_player_health_changed():
	pass

func _on_item_inserted():
	for listing in self.item_display.get_children():
		listing.queue_free()
	
	for item in self.items:
		var instance = self.item_listing.instance()
		instance.get_node("Name").text = item["name"]
		
		self.item_display.add_child(instance)

func get_equipment():
	return

func insert_item(metadata, quantity=1):
	for item in range(quantity):
		self.items.append(metadata)
	
	emit_signal("item_inserted")