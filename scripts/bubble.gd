class_name Bubble extends Sprite2D

var destination: Vector2;
var movement_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if destination and !movement_tween:
		self.movement_tween = create_tween()
		self.movement_tween.tween_property(self, "position", destination, 20).from_current()
