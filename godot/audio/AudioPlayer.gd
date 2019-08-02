extends Node2D

onready var audio_node = $AudioStreamPlayer2D

func _ready():
	audio_node.connect("finished", self, "free_self")
	audio_node.stop()

func play_sound(sound, position=null, pitch=1.0):
	audio_node.stream = load(sound)
	audio_node.pitch_scale = pitch
	
	if position != null:
		self.position = position
	
	audio_node.play()

func free_self():
	audio_node.stop()
	queue_free()