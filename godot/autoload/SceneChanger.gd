extends Node

var current_scene = null

func _ready():
	current_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)

func change_scene(path):
	# Ensure that the scene isn't changed when code from the current scene is running
	call_deferred("_deferred_scene_change", path)

func _deferred_scene_change(path):
	# It is now safe to remove the current scene
	current_scene.free()
	
	# Load the new scene to be attached to the graph
	var new_scene = ResourceLoader.load(path)
	current_scene = new_scene.instance()

	# Add the new scene to the graph
	get_tree().root.add_child(current_scene)
	get_tree().set_current_scene(current_scene)