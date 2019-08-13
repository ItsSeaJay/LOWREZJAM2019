extends Line2D

export var decay_rate = 1.0

var decay_delta = 1.0

func _process(delta):
	self.decay_delta = max(self.decay_delta - delta * decay_rate, 0.0)
	self.default_color.a = self.decay_delta
	
	if self.decay_delta == 0.0:
		self.queue_free()