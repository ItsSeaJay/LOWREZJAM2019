extends Button

onready var examine_panel = preload("res://interface/screens/inventory/panels/examine/ExaminePanel.tscn")

var key

func _pressed():
	var description = Database.tables["items"][key]["description"]
	var instance = examine_panel.instance()
	instance.get_node("ScrollContainer/VBoxContainer/DescriptionLabel").text = description
	
	PlayerData.instance.get_node("Interface/Inventory/MarginContainer").add_child(instance)