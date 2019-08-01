extends Camera2D

export(NodePath) var target

func _process(delta):
	position = get_node(target).position