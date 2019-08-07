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
	
	for item in items:
		var instance = item_listing.instance()
		var label_name = instance.get_node("Name")
		label_name.text = item["name"]
		
		self.item_display.add_child(instance)

func _process(delta):
	# Ensure that the inventory screen can always be closed
	if Input.is_action_just_pressed("ui_cancel") and not animation_player.is_playing():
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
	for listing in self.item_display.get_children():
		listing.queue_free()
	
	for item in self.items:
		var instance = self.item_listing.instance()
		instance.get_node("Button").text = item["name"]
		
		self.item_display.add_child(instance)

func get_item_quanities():
	pass

func get_equipment():
	return

func insert_item(metadata, quantity=1):
	for item in range(quantity):
		self.items.append(metadata)
	
	emit_signal("item_inserted")

func get_item(path):
	var file = File.new()
	
	assert(file.file_exists(path))
	
	file.open(path, file.READ)
	
	var contents = file.get_as_text()
	var json = JSON.parse(contents)
	
	file.close()
	
	return json.result