extends Polygon2D

var hits: int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var area: Area2D = get_node("Area2D")
	area.area_entered.connect(self.deduct_hit)

func deduct_hit(_area: Area2D):
	self.hits -= 1
	prints(self.name, "hits remaining", self.hits)
	if self.hits <= 0:
		prints(self.name, "no more rock")
		self.queue_free()
