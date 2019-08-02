extends Control

onready var item_listing = preload("res://interface/inventory/item/ItemListing.tscn")
onready var item_display = $ScrollContainer/VBoxContainer

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

func _ready():
	self.connect("visibility_changed", self, "_on_visibility_changed")
	
	var depth = 0
	
	for item in items:
		var instance = item_listing.instance()
		var label_name = instance.get_node("Name")
		label_name.text = item["name"]
		
		self.item_display.add_child(instance)

func _input(event):
	if event is InputEventAction:
		if event.action == "ui_cancel":
			self.visible = false

func _on_visibility_changed():
	get_tree().paused = self.visible