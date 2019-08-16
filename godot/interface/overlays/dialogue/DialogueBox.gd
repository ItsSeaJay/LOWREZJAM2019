extends Control

onready var label = $HBoxContainer/VBoxContainer/PanelContainer/TextContainer/Label
onready var animation_player = $AnimationPlayer
onready var dialogue_prompt = $HBoxContainer/VBoxContainer/PanelContainer/CursorContainer/VBoxContainer/TextureRect

var metadata
var text_raw
var text_formatted
var text_display_index = 0
var text_scroll_speed = 8.0
var cursor_position = 0.0
var cursor_position_last = 0.0

func _ready():
	get_tree().paused = true

func _process(delta):
	label.text = text_formatted[text_display_index].substr(0, self.cursor_position)
	self.cursor_position = min(
		self.cursor_position + (text_scroll_speed * delta),
		self.text_formatted[self.text_display_index].length()
	)
	
	self.dialogue_prompt.visible = (self.cursor_position == self.text_formatted[self.text_display_index].length())
	
	if self.dialogue_prompt.visible:
		if Input.is_action_just_pressed("move_interact"):
			if text_display_index == text_formatted.size() - 1:
				self.dismiss()
			else:
				self.text_display_index += 1
	else:
		if Input.is_action_just_pressed("move_interact"):
			self.cursor_position = self.text_formatted[self.text_display_index].length()
	
	self.cursor_position_last = self.cursor_position

func dismiss():
	get_tree().paused = false
	queue_free()

func set_text(text):
	self.text_raw = text
	
	if text is Array:
		text_formatted = text
	else:
		self.text_formatted = format_text(text)

func format_text(text):
	return text.split("\n")