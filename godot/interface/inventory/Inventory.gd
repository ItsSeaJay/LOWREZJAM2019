extends Control

onready var item_listing = preload("res://interface/inventory/item/ItemListing.tscn")
onready var item_display = $ScrollContainer/VBoxContainer
onready var cursor = $Cursor

var items = []
var options = []
var option_selected = 0

signal item_inserted

signal cursor_moved
signal cursor_selected

func _ready():
	self.connect("visibility_changed", self, "_on_visibility_changed")
	self.connect("item_inserted", self, "_on_item_inserted")
	self.connect("cursor_moved", self, "_on_cursor_moved")
	
	for item in items:
		var instance = item_listing.instance()
		var label_name = instance.get_node("Name")
		label_name.text = item["name"]
		
		self.item_display.add_child(instance)
	
	options = item_display.get_children()

func _process(delta):
	# Allow the inventory screen to be opened and closed
	if Input.is_action_just_pressed("ui_cancel"):
		self.visible = not self.visible

func _on_visibility_changed():
	get_tree().paused = self.visible

func _on_item_inserted():
	for listing in self.item_display.get_children():
		listing.queue_free()
	
	for item in self.items:
		var instance = self.item_listing.instance()
		instance.get_node("Name").text = item["name"]
		
		self.item_display.add_child(instance)

func _on_cursor_moved():
	cursor.position = options[option_selected].get_position()

func insert_item(metadata, quantity=1):
	for item in range(quantity):
		self.items.append(metadata)
	
	emit_signal("item_inserted")

func load_equipment_table():
	var table = {}
	
	var file = File.new()
	file.open("res://data/equipment.json", file.READ)
	
	var contents = file.get_as_text()
	var json = JSON.parse(contents)
	
	file.close()
	
	return json.result