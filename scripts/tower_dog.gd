class_name TowerDog extends Sprite2D

var targets = []
var current_target: Area2D
var attack_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collision_area: Area2D = get_node("Area2D")
	collision_area.area_entered.connect(enemy_detected)
	collision_area.area_exited.connect(enemy_lost)

func enemy_detected(intruder: Area2D) -> void:
	prints("detected:", intruder)
	targets.push_front(intruder)
	if !current_target:
		init_attack_cycle()

func init_attack_cycle() -> void:
	self.attack_tween = create_tween()
	self.attack_tween.tween_callback(try_throw_rock as Callable)
	self.attack_tween.tween_interval(2.0)
	self.attack_tween.set_loops()
		
func enemy_lost(escapee: Area2D) -> void:
	prints("target lost:", escapee)
	self.targets.erase(escapee)
	if escapee == self.current_target:
		self.current_target = null
		
func try_throw_rock() -> void:
	if len(self.targets) == 0:
		return

	if !self.current_target or self.current_target.is_queued_for_deletion():
		self.current_target = targets.pop_back()
		prints("new target", self.current_target)

	prints("throwing rock at", self.current_target)
	
	var rock: Polygon2D = get_node("Rock").duplicate()
	self.add_child(rock)
	rock.visible = true;
	
	rock.position = Vector2.ZERO
	rock.look_at(current_target.global_position)

	var target_position: Vector2 = Vector2.RIGHT.rotated(rock.rotation) * (12 * 3 * 2);
	
	var throw_tween = create_tween()
	throw_tween.tween_property(rock, "position", target_position, 0.3)
	throw_tween.tween_callback(rock.queue_free);
	
	
	
