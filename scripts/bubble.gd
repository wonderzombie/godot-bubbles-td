class_name Bubble extends Sprite2D

signal pop(stats: BubbleStats)
signal escaped(b: Bubble, stats: BubbleStats)

@export var stats: BubbleStats
@export var hits_remaining: int = 1

@onready var collision_area: Area2D = get_node(^"Area2D")

var value: int:
	get(): return self.stats.value
var speed: float:
	get(): return self.stats.speed
var color: Color:
	get(): return self.stats.color

var destination: Vector2;
var movement_tween: Tween
var escaped_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.collision_area.area_entered.connect(get_hit)
	self.escaped_tween = create_tween()
	self.escaped_tween.tween_callback(self.check_escaped)
	self.escaped_tween.tween_interval(0.5)
	self.escaped_tween.set_loops()

func set_stats(s: BubbleStats) -> void:
	self.stats = s
	self.hits_remaining = s.max_hits
	self.self_modulate = s.color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func start() -> void:
	self._set_active(true)
	self.movement_tween = create_tween()
	self.movement_tween.tween_property(self, "position", destination, self.stats.speed).from_current()

func _set_active(active: bool) -> void:
	self.collision_area.set_deferred("monitorable", active)
	self.collision_area.set_deferred("monitoring", active)
	self.set_deferred("visible", active)
	self.set_deferred("process_mode", 
		ProcessMode.PROCESS_MODE_INHERIT if active else ProcessMode.PROCESS_MODE_DISABLED)

func get_hit(_hitter: Area2D) -> void:
	if !self.movement_tween:
		return
	
	self.hits_remaining -= 1
	if self.hits_remaining > 0:
		return
	
	self._set_active(false)
	movement_tween.kill()
	self.collision_area.set_deferred("monitorable", false)
	self.collision_area.set_deferred("monitoring", false)
	
	var left = Vector2.LEFT * 1 + self.position
	var right = Vector2.RIGHT * 1 + self.position
	
	var hit = get_tree().create_tween()
	hit.tween_property(self, "position", left, 0.05).from_current()
	hit.tween_property(self, "position", right, 0.05).from_current()
	hit.set_loops(20)
	hit.tween_property(self, "modulate:a", 0.0, 0.5)
	hit.tween_callback(self.queue_free)
	
	pop.emit(self.stats)
	

func check_escaped() -> void:
	if self.position == destination:
		self.escaped.emit(self, self.stats.value)
