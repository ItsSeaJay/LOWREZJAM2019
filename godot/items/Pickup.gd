extends Node

onready var tag = "unknown"
onready var metadata = load_metadata()

const item_table_path = "res://data/equipment.json"

func load_metadata():
	var items = {}
	
	var file = File.new()
	file.open(item_table_path, file.READ)
	
	var contents = file.get_as_text()
	var json = JSON.parse(contents)
	
	file.close()
	
	return json.result[tag]