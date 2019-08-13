extends Node2D

onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.connect("animation_finished", self, "_on_AnimationPlayer_finished")
	animation_player.play("fade")

func _on_AnimationPlayer_finished():
	self.queue_free()