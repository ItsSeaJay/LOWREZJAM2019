extends Area2D

class_name Door

export(String) var path = "res://maps/test/TestMapGrassland.tscn"

func _ready():
	self.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	get_tree().change_scene(path)