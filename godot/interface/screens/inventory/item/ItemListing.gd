extends HBoxContainer

export(String) var key = "example"

onready var button = $Button
onready var command_box = self.get_node("../../../../../PrimaryContainer/RightContainer/CommandBox/VBoxContainer")

var metadata

func _ready():
	self.button.text = Database.tables["items"][key]["name"]
	
	self.button.connect("button_down", self, "_on_Button_clicked")

func _on_Button_clicked():
	if self.command_box.get_child_count() > 0:
		for command in command_box.get_children():
			command.queue_free()
	
	if Database.tables["items"][key].has("commands"):
		for command in Database.tables["items"][key]["commands"]:
			var command_resource = load(command)
			assert(command_resource != null)
			
			var command_listing = command_resource.instance()
			command_listing.key = key
			
			command_box.add_child(command_listing)