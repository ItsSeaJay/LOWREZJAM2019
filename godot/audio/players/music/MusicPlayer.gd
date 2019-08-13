extends "res://audio/players/AudioPlayer.gd"

func _ready():
	audio_node = $AudioStreamPlayer

func play_music(sound):
	audio_node = $AudioStreamPlayer
	audio_node.stream = load(sound)
	audio_node.play()