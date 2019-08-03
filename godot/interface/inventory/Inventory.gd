extends Control

onready var item_listing = preload("res://interface/inventory/item/ItemListing.tscn")
onready var item_display = $ScrollContainer/VBoxContainer
onready var cursor = $Cursor

onready var equipment_table = load_equipment_table()

var items = []
var options = []
var option_selected = 0

signal cursor_moved
signal cursor_selected

func _ready():
	self.connect("visibility_changed", self, "_on_visibility_changed")
	self.connect("cursor_moved", self, "_on_cursor_moved")
	
	items.append(equipment_table["machine_pistol"])
	print(items[0]["name"])
	
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
	
	# Allow the cursor to be moved to select different items
	if Input.is_action_just_pressed("ui_down"):
		option_selected = (option_selected + 1) % options.size()
		emit_signal("cursor_moved")

func _on_visibility_changed():
	get_tree().paused = self.visible

func _on_cursor_moved():
	cursor.position = options[option_selected].get_position()

func load_equipment_table():
	var table = {}
	
	var file = File.new()
	file.open("res://data/equipment.json", file.READ)
	
	var contents = file.get_as_text()
	var json = JSON.parse(contents)
	
	file.close()
	
	return json.result