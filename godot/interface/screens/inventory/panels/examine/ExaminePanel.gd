extends PanelContainer

onready var button_back = $ScrollContainer/VBoxContainer/BackButton

func _ready():
	button_back.connect("button_down", self, "_on_BackButton_down")

func _on_BackButton_down():
	self.queue_free()