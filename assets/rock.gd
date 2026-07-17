extends Polygon2D

var hits: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var area: Area2D = get_node("Area2D")
	area.area_entered.connect(self.deduct_hit)

func deduct_hit(_area: Area2D):
	self.hits -= 1
	if hits == 0:
		self.queue_free()
