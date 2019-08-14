extends Control

export(float) var visibility_delay = 3.0

var visibility_delta : float = visibility_delay

func _ready():
	self.visible = false

func _process(delta):
	visibility_delta = max(visibility_delta - delta, 0.0)
	
	if visibility_delta == 0.0:
		self.visible = true
	
	if self.player_moving():
		self.queue_free()

func player_moving():
	return PlayerData.instance.direction != Vector2.ZERO