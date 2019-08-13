extends "res://audio/players/AudioPlayer.gd"

func _ready():
	self.audio_node = $AudioStreamPlayer2D
	audio_node.connect("finished", self, "free_self")

func play_sound(sound, position, pitch=1.0):
	audio_node.stream = load(sound)
	audio_node.pitch_scale = pitch
	
	self.position = position
	
	audio_node.play()