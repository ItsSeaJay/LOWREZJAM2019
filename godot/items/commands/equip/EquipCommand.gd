extends Button

onready var player = get_tree().root.get_node("/root/Game/Characters/Player")

var key

func _pressed():
	player.equip(Database.tables["items"][key])