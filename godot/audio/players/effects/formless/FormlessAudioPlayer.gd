extends "res://audio/players/AudioPlayer.gd"

func _ready():
	self.audio_node = $AudioStreamPlayer

func play_sound(sound, pitch=1.0):
	self.audio_node.stream = load(sound)
	self.audio_node.pitch_scale = pitch
	
	self.audio_node.play()