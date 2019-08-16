extends Area2D

export(String, FILE) var sound_stream
export(Vector2) var sound_offset

const Player = preload("res://characters/player/Player.gd")

func _ready():
	self.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is Player:
		AudioSystem.play_sound_positional(
			self.sound_stream,
			self.position + self.sound_offset
		)
		self.queue_free()