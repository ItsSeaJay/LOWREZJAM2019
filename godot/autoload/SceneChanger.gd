extends Node

onready var animation_player : AnimationPlayer = $AnimationPlayer

var current_scene = null

signal scene_changed

func _ready():
	# Get the current scene attached to the root node
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func change_scene(path, transition_in="fade", transition_out=null):
	get_tree().paused = true
	animation_player.play(transition_in)
	
	yield(animation_player, "animation_finished")
	
	call_deferred("_deferred_scene_change", path)
	
	# Change the animation based on whether an asymmetrical transition
	# is being used
	if transition_out != null and transition_out != transition_in:
		animation_player.play(transition_out)
	else:
		animation_player.play_backwards(transition_in)
	
	yield(animation_player, "animation_finished")
	
	get_tree().paused = false
	emit_signal("scene_changed")

func _deferred_scene_change(path):
	# It is now safe to remove the current scene
	current_scene.free()
	
	# Load the new scene to be attached to the graph
	var new_scene = ResourceLoader.load(path)
	current_scene = new_scene.instance()

	# Add the new scene to the graph
	get_tree().root.add_child(current_scene)
	get_tree().set_current_scene(current_scene)