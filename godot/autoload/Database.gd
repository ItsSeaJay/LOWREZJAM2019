extends Node

func load_item_metadata(path):
	var file = File.new()
	
	assert(file.file_exists(path))
	
	file.open(path, file.READ)
	
	var json = JSON.parse(file.get_as_text())
	
	file.close()
	
	var metadata = json.result
	metadata["json_file"] = path
	
	return metadata