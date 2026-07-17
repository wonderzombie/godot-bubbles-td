class_name TowerDog extends Sprite2D

var current_target: Area2D
var attack_tween: Tween
var thrown_rocks: int
var detection_area: Area2D

@export var detection_radius: int = 36
@export var attack_cooldown: float = 2.05

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.detection_area = get_node("Area2D")
	detection_area.area_entered.connect(enemy_detected)
	detection_area.area_exited.connect(enemy_lost)
	
	var coll_shape: CollisionShape2D = detection_area.get_node("CollisionShape2D");
	if coll_shape.shape is CircleShape2D:
		coll_shape.shape.radius = detection_radius
	
func enemy_detected(intruder: Area2D) -> void:
	prints("detected:", named(intruder))
	if !self.attack_tween:
		init_attack_cycle()

func init_attack_cycle() -> void:
	self.attack_tween = create_tween()
	self.attack_tween.tween_callback(try_throw_rock as Callable)
	self.attack_tween.tween_interval(self.attack_cooldown)
	self.attack_tween.set_loops()
		
func enemy_lost(lost: Area2D) -> void:	
	prints("target lost:", named(lost))
	if lost == self.current_target:
		self.current_target = null
		
func try_throw_rock() -> void:
	if !detection_area.has_overlapping_areas():
		return

	if !self.current_target or self.current_target.is_queued_for_deletion():
		self.current_target = detection_area.get_overlapping_areas().front()

	prints("throwing rock at", named(self.current_target))
	
	var rock = get_node("Rock").duplicate()
	self.add_child(rock)
	rock.name = "rock%d" % thrown_rocks
	rock.visible = true;
	
	rock.position = Vector2.ZERO
	rock.look_at(current_target.global_position)

	var target_position: Vector2 = Vector2.RIGHT.rotated(rock.rotation) * (12 * 3 * 1);
	
	var throw_tween = create_tween()
	throw_tween.tween_property(rock, "position", target_position, 0.3)
	throw_tween.tween_callback(rock.queue_free);
	thrown_rocks += 1
	
	
func named(area: Area2D) -> String:
	return area.get_parent().name
	
