class_name TowerDog extends Sprite2D

signal clicked

@export var stats: TowerStats
@export var upgrades: TowerUpgradesList

var detection_radius: float:
	get(): return stats.detection_radius
var attack_cooldown: float:
	get(): return stats.attack_cooldown
var rock_range: float:
	get(): return stats.rock_range
var hits_per_rock: int:
	get(): return stats.hits_per_rock

var cooldown: float
var attack_tween: Tween
var thrown_rocks: int
var detection_area: Area2D
var current_target: Area2D
var coll_shape: CollisionShape2D
var timer: Timer

func _ready() -> void:
	self.detection_area = get_node("Area2D")
	self.detection_area.area_entered.connect(enemy_detected)
	self.detection_area.area_exited.connect(enemy_lost)

	self.coll_shape = detection_area.get_node("CollisionShape2D");
	if coll_shape.shape is CircleShape2D:
		coll_shape.shape.radius = detection_radius

	self.timer = Timer.new()
	timer.wait_time = stats.attack_cooldown
	timer.one_shot = true
	self.add_child(timer)

func enemy_detected(intruder: Area2D) -> void:
	prints("detected:", named(intruder))
	if !self.current_target:
		self.current_target = intruder


func _process(_delta: float) -> void:
	if !detection_area.has_overlapping_areas():
		return

	if !current_target or current_target.is_queued_for_deletion():
		self.current_target = detection_area.get_overlapping_areas().front()

	if timer.is_stopped() || timer.time_left == 0:
		prints("time left is 0")
		try_throw_rock(self.current_target)
		timer.start()

func enemy_lost(lost: Area2D) -> void:
	prints("target lost:", named(lost))
	if lost == self.current_target:
		self.current_target = null
	if !detection_area.has_overlapping_areas():
		self.timer.stop()

func try_throw_rock(target: Area2D) -> bool:
	var rock: Rock = get_node("Rock").duplicate()
	rock.hits = self.hits_per_rock

	self.add_child(rock)
	rock.name = "rock%d" % thrown_rocks
	rock.visible = true;

	rock.position = Vector2.ZERO
	rock.look_at(target.global_position)

	var target_position: Vector2 = Vector2.RIGHT.rotated(rock.rotation) * self.rock_range;

	var throw_tween = create_tween()
	throw_tween.tween_property(rock, "position", target_position, 0.25)
	throw_tween.tween_callback(rock.queue_free);
	thrown_rocks += 1
	prints("! rock away !")
	return true

func named(area: Area2D) -> String:
	return area.get_parent().name

func _unhandled_input(event: InputEvent) -> void:
	if !self.get_rect().has_point(self.get_local_mouse_position()):
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		prints("clicked me", self)
		self.clicked.emit()
