extends Control

onready var item_listing = preload("res://interface/inventory/item/ItemListing.tscn")
onready var item_display = $ScrollContainer/VBoxContainer
onready var cursor = $Cursor

var items = [
	{
		"name": "Egg Box"
	},
	{
		"name": "Milk"
	},
	{
		"name": "Butter"
	},
	{
		"name": "Sugar"
	},
	{
		"name": "Silver Spoon"
	}
]
var options = []
var option_selected = 0

func _ready():
	self.connect("visibility_changed", self, "_on_visibility_changed")
	
	for item in items:
		var instance = item_listing.instance()
		var label_name = instance.get_node("Name")
		label_name.text = item["name"]
		
		self.item_display.add_child(instance)
	
	options = item_display.get_children()
	print(options)

func _process(delta):
	# Allow the inventory screen to be opened and closed
	if Input.is_action_just_pressed("ui_cancel"):
		self.visible = not self.visible
	
	if Input.is_action_just_pressed("ui_down"):
		option_selected = (option_selected + 1) % options.size()

func _on_visibility_changed():
	get_tree().paused = self.visible
	self.grab_click_focus()
	self.grab_focus()