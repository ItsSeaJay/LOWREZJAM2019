extends HBoxContainer

onready var button = $Button
onready var command_box = self.get_node("../../../../../PrimaryContainer/RightContainer/CommandBox/VBoxContainer")

var json_file = "res://items/example/example.json"
var metadata

func _ready():
	self.metadata = Database.load_item_metadata(json_file)
	self.button.text = self.metadata["name"]
	
	self.button.connect("button_down", self, "_on_Button_clicked")

func _on_Button_clicked():
	if self.command_box.get_child_count() > 0:
		for command in command_box.get_children():
			command.queue_free()
	
	if self.metadata.has("commands"):
		for command in self.metadata["commands"]:
			var command_resource = load(command)
			assert(command_resource != null)
			
			var command_listing = command_resource.instance()
			command_listing.metadata = self.metadata
			
			command_box.add_child(command_listing)