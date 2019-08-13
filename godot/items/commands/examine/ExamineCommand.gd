extends Button

onready var examine_panel = preload("res://interface/screens/inventory/panels/examine/ExaminePanel.tscn")

var key

func _pressed():
	print(Database.tables["items"][key]["description"])
	var instance = examine_panel.instance()