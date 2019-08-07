extends Control

onready var label = $HBoxContainer/VBoxContainer/PanelContainer/TextContainer/Label
onready var animation_player = $AnimationPlayer

var metadata
var text_raw
var text_formatted
var text_display_index = 0
var text_scroll_speed = 4.0
var cursor_position = 0.0

func _ready():
	self.connect("dismissed", self, "_on_dismissed")
	get_tree().paused = true

func _process(delta):
	label.text = text_formatted[text_display_index].substr(0, self.cursor_position)
	self.cursor_position = min(
		self.cursor_position + (text_scroll_speed * delta),
		self.text_formatted[self.text_display_index].length()
	)
	
	if text_display_index == text_formatted.size() - 1:
		if Input.is_action_just_pressed("move_interact"):
			self.dismiss()

func dismiss():
	get_tree().paused = false
	queue_free()

func set_text(text):
	self.text_raw = text
	self.text_formatted = format_text(text)

func format_text(text) -> Array:
	var display_list = [ text ]
	
	return display_list