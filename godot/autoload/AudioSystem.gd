extends Node

onready var audio_player_positional = preload("res://audio/players/effects/positional/PositionalAudioPlayer.tscn")
onready var audio_player_formless = preload("res://audio/players/effects/formless/FormlessAudioPlayer.tscn")

onready var music_player = preload("res://audio/players/music/MusicPlayer.tscn")

func play_sound_formless(sound, pitch=1.0):
	var instance = audio_player_formless.instance()
	
	get_tree().root.add_child(instance)
	instance.play_sound(sound, pitch)

func play_sound_positional(sound, position, pitch=1.0):
	var instance = audio_player_positional.instance()
	
	get_tree().root.add_child(instance)
	instance.play_sound(sound, position, pitch)

func play_music(sound):
	var instance = music_player.instance()
	
	call_deferred("_deferred_instantiate", instance)
	instance.play_music(sound)
	
	return instance

func _deferred_instantiate(instance):
	get_tree().root.add_child(instance)