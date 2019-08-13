extends Node2D

onready var audio_node

func free_self():
	self.audio_node.stop()
	queue_free()