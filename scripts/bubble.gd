class_name Bubble extends Sprite2D

signal pop(b: Bubble)
signal escaped(b: Bubble)

@export var hits_remaining: int = 1

@onready var collision_area: Area2D = get_node(^"Area2D")

var value: int:
	get(): return stats.value if stats else 0
var speed: float:
	get(): return stats.speed if stats else 0.0
var color: Color:
	get(): return stats.color if stats else self.self_modulate

var has_escaped: bool
var next_waypoint: Node2D
var movement_tween: Tween
var escaped_tween: Tween
var stats: BubbleStats
var waypoints: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.collision_area.area_entered.connect(get_hit)
	self.set_active(false)

func set_stats(s: BubbleStats) -> void:
	self.stats = s
	self.hits_remaining = s.max_hits
	self.self_modulate = s.color

func start(the_waypoints: Array[Node]) -> void:
	self.waypoints = the_waypoints
	prints("waypoints", waypoints)
	
	self.position = waypoints.front().position
	self.next_waypoint = waypoints.front() as Node2D
	
	self.set_active(true)
 
func _process(delta: float) -> void:
	var difference := self.next_waypoint.position - self.position
	var normalized := difference.normalized()
	var movement := normalized * self.stats.speed * delta
	if difference <= movement:
		self.position = self.next_waypoint.position
	else:
		self.position += movement
	
	if self.position == self.next_waypoint.position:
		if self.waypoints.back() == self.next_waypoint:
			set_active(false)
			self.escaped.emit(self)
			self.has_escaped = true
		else:
			prints("presently achieved waypoint", next_waypoint, next_waypoint.position, self.position)
			var next_waypoint_idx = self.next_waypoint.get_index() + 1	
			prints("next waypoint is", next_waypoint_idx)
			next_waypoint = self.waypoints.get(next_waypoint_idx) as Node2D
		
	

func stop() -> void:
	if self.movement_tween:
		self.movement_tween.kill()

func set_active(active: bool) -> void:
	self.collision_area.set_deferred("monitorable", active)
	self.collision_area.set_deferred("monitoring", active)
	self.set_deferred("visible", active)
	self.set_deferred("process_mode", 
		ProcessMode.PROCESS_MODE_INHERIT if active else ProcessMode.PROCESS_MODE_DISABLED)

func get_hit(_hitter: Area2D) -> void:
	self.hits_remaining -= 1
	prints("! hits remaining", self.hits_remaining)
	if self.hits_remaining > 0:
		return
	
	var left = Vector2.LEFT * 1 + self.position
	var right = Vector2.RIGHT * 1 + self.position
	
	var hit = get_tree().create_tween()
	hit.tween_property(self, "position", left, 0.05).from_current()
	hit.tween_property(self, "position", right, 0.05).from_current()
	hit.set_loops(20)
	hit.tween_property(self, "modulate:a", 0.0, 0.5)
	hit.tween_callback(self.queue_free)
	
	pop.emit(self)
	
