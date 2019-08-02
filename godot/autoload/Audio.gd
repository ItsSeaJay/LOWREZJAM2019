extends Node

onready var audio_player = preload("res://audio/AudioPlayer.tscn")

func play_sound(sound, position=null, pitch=1.0):
	var instance = audio_player.instance()
	get_tree().root.add_child(instance)
	instance.play_sound(sound, position, pitch)