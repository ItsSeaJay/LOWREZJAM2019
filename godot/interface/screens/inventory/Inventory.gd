extends Control

onready var item_listing = preload("res://interface/screens/inventory/item/ItemListing.tscn")

onready var item_display = $MarginContainer/PanelContainer/VBoxContainer/SecondaryContainer/PanelContainer/ScrollContainer/VBoxContainer
onready var health_display = $MarginContainer/PanelContainer/VBoxContainer/PrimaryContainer/LeftContainer/HealthDisplay

onready var animation_player : AnimationPlayer = $AnimationPlayer

var items = {}

signal item_inserted
signal item_removed

func _ready():
	self.call_deferred("_deferred_connect")

func _process(delta):
	# Ensure that the inventory screen can always be closed
	if Input.is_action_just_pressed("ui_cancel") and not animation_player.is_playing() and self.visible:
		get_tree().paused = false
		animation_player.play("close")
	
	if Input.is_action_just_pressed("ui_accept"):
		PlayerData.instance.damage(10)

func _on_Player_health_changed():
	var background_shader : ShaderMaterial = health_display.get_node("Background").material as ShaderMaterial
	var animation_player : AnimationPlayer = health_display.get_node("AnimationPlayer")
	var health : float = float(PlayerData.instance.health)
	var health_max : float = float(PlayerData.instance.health_max)
	var animation_speed_max : float = 1.0
	var animation_speed_min : float = 0.5
	assert(animation_speed_min > 0.0)
	assert(animation_speed_max > animation_speed_min)
	var animation_speed : float = ((animation_speed_max - animation_speed_min) * (health / health_max)) + animation_speed_min
	var health_full_color = Color.green
	var health_half_color = Color.yellow
	var health_low_color = Color.red
	
	animation_player.set_speed_scale(animation_speed)
	
	if PlayerData.instance.health > PlayerData.instance.health_max / 2:
		background_shader.set_shader_param("input_color", health_full_color)
		animation_player.play("full_health")
	else:
		if PlayerData.instance.health > PlayerData.instance.health_max / 4:
			background_shader.set_shader_param("input_color", health_half_color)
			animation_player.play("half_health")
		else:
			background_shader.set_shader_param("input_color", health_low_color)
			animation_player.play("quarter_health")

func _on_Inventory_changed():
	update_item_list()

func _deferred_connect():
	self.connect("item_inserted", self, "_on_Inventory_changed")
	self.connect("item_removed", self, "_on_Inventory_changed")
	PlayerData.instance.connect("health_changed", self, "_on_Player_health_changed")

func insert_item(key, quantity=1):
	if self.items.has(key):
		self.items[key] += quantity
	else:
		self.items[key] = quantity
	
	emit_signal("item_inserted")

func get_item(item_name):
	var keys = self.items.keys()
	
	for item in keys:
		var item_name_current = Database.tables["items"][item]["name"]
		
		if item_name == item_name_current:
			return Database.tables["items"][item]
	
	return null

func remove_item(key, quantity=1):
	assert(self.items.has(key))
	
	if (self.items[key] > quantity):
		self.items[key] -= quantity
	else:
		self.items.erase(key)
	
	emit_signal("item_removed")

func find_first_item_instance(item_name):
	for index in range(self.items.size()):
		if self.items[index]["name"] == item_name:
			return index
	
	return null

func update_item_list():
	if self.item_display.get_child_count() > 0:
		for listing in self.item_display.get_children():
			listing.queue_free()
	
	for item in self.items.keys():
		var instance = self.item_listing.instance()
		instance.key = item
		instance.get_node("MarginContainer/QuantityLabel").text = str(self.items[item])
		
		self.item_display.add_child(instance)