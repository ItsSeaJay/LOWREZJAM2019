extends Node

onready var tables = {
	"items": load_json_from_file("res://data/items.json")
}

func load_json_from_file(path):
	var file = File.new()
	assert(file.file_exists(path))
	file.open(path, file.READ)
	
	var json = JSON.parse(file.get_as_text())
	assert(json.error == OK)
	
	file.close()
	
	return json.result