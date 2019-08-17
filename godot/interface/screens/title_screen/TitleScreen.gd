extends Control

onready var button_start : Button = $HBoxContainer/VBoxContainer/StartButton
onready var button_quit : Button = $HBoxContainer/VBoxContainer/QuitButton

func _ready():
	var window_width = 1024
	var window_height = 768
	
	OS.window_size = Vector2(window_width, window_height)
	OS.window_position = (OS.get_screen_size() / 2.0) - (OS.window_size / 2.0)
	
	get_tree().paused = false
	
	button_start.connect("button_down", self, "_on_StartButton_pressed")
	button_quit.connect("button_down", self, "_on_QuitButton_pressed")

func _on_StartButton_pressed():
	SceneChanger.change_scene("res://maps/interior/cave/CaveInterior.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()