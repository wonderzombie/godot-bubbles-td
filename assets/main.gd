extends Node2D

const DEFAULT_SPEED = 20

var bubbles_spawned = 0;

@export var score = 0;
@export var lives = 60;

var ghost_tower: DogButton;

var score_twn
var lives_twn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Toolbar.selected.connect(selected_tower)
	%Lives.text = "LIVES: %d" % lives


func _unhandled_key_input(event: InputEvent) -> void:
	var color = Color.TRANSPARENT
	var speed = DEFAULT_SPEED
	var hits = 1

	if event.is_action_pressed("next_round"):
		pass
	elif event.is_action_pressed("first_balloon"):
		color = Color.RED
		speed = DEFAULT_SPEED
	elif event.is_action_pressed("second_balloon"):
		color = Color.BLUE
		speed = DEFAULT_SPEED * 0.95
		hits = 2
	elif event.is_action_pressed("third_balloon"):
		color = Color.GREEN
		speed = DEFAULT_SPEED * 0.80
		hits = 3
	else:
		return
		
	var value = 5 + (5 * (hits + 1))
	
	var start_wp: Marker2D = %Waypoints.get_child(0);
	var end_wp: Marker2D = %Waypoints.get_child(-1);
	prints("start is %s and end is %s" % [start_wp, end_wp])
	
	var new_bubble: Bubble = %Bubble.duplicate();
	
	new_bubble.position = start_wp.position;
	new_bubble.destination = end_wp.position;
	new_bubble.speed = speed;
	new_bubble.modulate = color;
	new_bubble.value = value;
	new_bubble.num_hits = hits;
	
	%Map.add_child(new_bubble);
	
	new_bubble.pop.connect(adjust_score)
	new_bubble.escaped.connect(adjust_lives)
	
	new_bubble.visible = true;
	bubbles_spawned += 1
	new_bubble.name = "bubble%d" % bubbles_spawned
	new_bubble.start()
	

func adjust_score(value: int) -> void:
	score += value
	prints("score is now", score)
	
	%Score.text = "SCORE: %s" % score

	if self.score_twn:
		self.score_twn.kill()

	if value > 0:
		%Score.modulate = Color.GREEN
		self.score_twn = create_tween()
		self.score_twn.tween_property(%Score, "modulate", Color.WHITE, 1)
	elif value < 0:
		%Score.modulate = Color.GOLD
		self.score_twn = create_tween()
		self.score_twn.tween_property(%Score, "modulate", Color.WHITE, 1)

func adjust_lives(bubble: Bubble, value: int) -> void:
	prints("adjust lives:", value)
	var adjusted_penalty = value / 5
	lives -= adjusted_penalty
	bubble.set_process_mode(PROCESS_MODE_DISABLED)
	bubble.visible = false
	bubble.queue_free()
	%Lives.text = "LIVES: %d" % lives
	%Lives.modulate = Color.RED
	
	if self.lives_twn:
		self.lives_twn.kill()
	
	self.lives_twn = create_tween()
	self.lives_twn.tween_property(%Lives, "modulate", Color.WHITE, 1)

func selected_tower(sprite: DogButton) -> void:
	match sprite.name:
		"DogButton1":
			self.ghost_tower = sprite.duplicate()
			self.add_child(ghost_tower)
			self.ghost_tower.position = self.get_local_mouse_position()

func _input(event) -> void:
	if !ghost_tower:
		return

	var map_pos = %Map.get_local_mouse_position()
	var cell_pos = %Map.local_to_map(map_pos)
	var tower_pos = %Map.map_to_local(cell_pos)
	self.ghost_tower.position = tower_pos
	
	#prints(event)
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var tile_data: TileData = %Map.get_cell_tile_data(cell_pos)
		
		var path = tile_data.get_custom_data("path") as bool
		if path:
			%Messages.add_message("can't place tower on path", Color.RED)
			prints("can't place tower on path at", cell_pos)
			return
		
		_maybe_place_tower(tower_pos)
			

func _maybe_place_tower(tower_pos):
	prints("clicked:", self.ghost_tower.position)
	
	var new_tower = ghost_tower.scene.instantiate()
	prints("spawning", new_tower.name, "at", tower_pos)
	
	%Map.add_child(new_tower)
	new_tower.position = tower_pos
	
	%Toolbar.last_selected = null
	
	adjust_score(-ghost_tower.cost)
	ghost_tower.queue_free()
