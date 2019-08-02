extends Node2D

onready var audio_node = $AudioStreamPlayer2D

func _ready():
	audio_node.connect("finished", self, "free_self")
	audio_node.stop()

func play_sound(sound, position=null):
	audio_node.stream = load(sound)
	audio_node.play()

func free_self():
	audio_node.stop()
	queue_free()