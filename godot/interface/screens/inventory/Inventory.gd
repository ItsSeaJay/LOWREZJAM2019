extends Control

onready var item_listing = preload("res://interface/screens/inventory/item/ItemListing.tscn")

onready var item_display = $MarginContainer/PanelContainer/VBoxContainer/SecondaryContainer/PanelContainer/ScrollContainer/VBoxContainer
onready var health_display = $MarginContainer/PanelContainer/VBoxContainer/PrimaryContainer/LeftContainer/HealthDisplay

onready var animation_player = $AnimationPlayer

onready var player = get_tree().root.get_node("/root/Game/Characters/Player")

var items = []

signal item_inserted

func _ready():
	self.connect("item_inserted", self, "_on_item_inserted")
	player.connect("health_changed", self, "_on_Player_health_changed")

func _process(delta):
	# Ensure that the inventory screen can always be closed
	if Input.is_action_just_pressed("ui_cancel") and not animation_player.is_playing() and self.visible:
			get_tree().paused = false
			animation_player.play("close")
	
	if Input.is_action_just_pressed("ui_accept"):
		player.damage(10)

func _on_Player_health_changed():
	var background_shader : ShaderMaterial = health_display.get_node("Background").material as ShaderMaterial
	var health_full_color = Color.green
	var health_half_color = Color.yellow
	var health_low_color = Color.red

func _on_item_inserted():
	update_item_list()

func get_item_quanities():
	pass

func insert_item(metadata, quantity=1):
	for item in range(quantity):
		self.items.append(metadata)
	
	emit_signal("item_inserted")

func update_item_list():
	if self.item_display.get_child_count() > 0:
		for listing in self.item_display.get_children():
			listing.queue_free()
	
	for item in self.items:
		var instance = self.item_listing.instance()
		instance.json_file = item["json_file"]
		
		self.item_display.add_child(instance)