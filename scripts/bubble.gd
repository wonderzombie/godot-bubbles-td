class_name Bubble extends Sprite2D

signal pop(award: int)

@export var speed: float = 20
@export var value: int = 5
@export var num_hits: int = 1

var destination: Vector2;
var movement_tween: Tween
var random_colors: Array[Color] = [
	Color.RED,
	Color.ORANGE,
	Color.YELLOW,
	Color.GREEN,
	Color.BLUE,
	Color.INDIGO,
	Color.VIOLET,
	Color.WHITE,
	Color.WHITE,
	Color.WHITE,
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collision_area: Area2D = get_node("Area2D")
	collision_area.area_entered.connect(get_hit)
	var choice = randi() % len(random_colors)
	self.modulate = random_colors[choice]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func start() -> void:
	self.movement_tween = create_tween()
	self.movement_tween.tween_property(self, "position", destination, self.speed).from_current()

func get_hit(_hitter: Area2D) -> void:
	movement_tween.kill()
	var left = Vector2.LEFT * 1 + self.position
	var right = Vector2.RIGHT * 1 + self.position
	
	pop.emit(self.value)
	
	var hit = get_tree().create_tween()
	hit.tween_property(self, "position", left, 0.05).from_current()
	hit.tween_property(self, "position", right, 0.05).from_current()
	hit.set_loops(20)
	hit.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	hit.tween_callback(self.queue_free)
