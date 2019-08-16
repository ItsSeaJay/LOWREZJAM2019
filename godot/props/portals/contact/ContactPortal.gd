extends Area2D

export(String, FILE, "*.tscn") var target_scene = "res://maps/default/DefaultMap.tscn"
export(String) var transition_in = "fade"
export(String) var transition_out = "fade"
export(Vector2) var destination_position = Vector2(0.0, 0.0)

func _ready():
	self.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is Player:
		PlayerData.target_position = self.destination_position
		SceneChanger.change_scene(self.target_scene, self.transition_in, self.transition_out)