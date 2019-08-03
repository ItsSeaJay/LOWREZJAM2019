extends Area2D

export(String, FILE, "*.tscn") var scene_path = "res://maps/default/DefaultMap.tscn"
export(Vector2) var destination = Vector2(0, 0)

func _ready():
	self.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body.name == "Player":
		PlayerData.position = destination
		SceneChanger.change_scene(scene_path)