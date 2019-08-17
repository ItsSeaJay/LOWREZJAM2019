extends Control

export(String, FILE) var title_screen = "res://interface/screens/title_screen/TitleScreen.tscn"

onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	animation_player.play("roll")

func _on_AnimationPlayer_animation_finished():
	SceneChanger.change_scene(self.title_screen)