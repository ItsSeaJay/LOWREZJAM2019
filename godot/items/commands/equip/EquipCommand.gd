extends Button

onready var player = get_tree().root.get_node("/root/Game/Characters/Player")

var metadata

func _pressed():
	player.equip(self.metadata)