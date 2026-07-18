extends Node2D

@export var score = 0
@export var lives = 60

var ghost_tower: DogButton
var bubbles_spawned = 0

var score_twn: Tween
var lives_twn: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Toolbar.selected.connect(selected_tower)
	%Lives.text = "LIVES: %d" % lives
	%Messages.text = ""


func _unhandled_key_input(event: InputEvent) -> void:
	var stats: BubbleStats

	if event.is_action_pressed("next_round"):
		stats = BubbleStats.STATS.values().pick_random()
	elif event.is_action_pressed("first_balloon"):
		stats = BubbleStats.STATS.get(BubbleStats.Ty.RED)
	elif event.is_action_pressed("second_balloon"):
		stats = BubbleStats.STATS.get(BubbleStats.Ty.BLUE)
	elif event.is_action_pressed("third_balloon"):
		stats = BubbleStats.STATS.get(BubbleStats.Ty.GREEN)
	else:
		return

	
	var start_wp: Marker2D = %Waypoints.get_child(0);
	var end_wp: Marker2D = %Waypoints.get_child(-1);
	prints("start is %s and end is %s" % [start_wp, end_wp])
	
	var new_bubble: Bubble = %Bubble.duplicate();
	new_bubble.set_stats(stats)

	%Map.add_child(new_bubble);
	new_bubble.position = start_wp.position;
	new_bubble.destination = end_wp.position;
	
	new_bubble.pop.connect(handle_pop)
	new_bubble.escaped.connect(handle_escape)
	
	bubbles_spawned += 1
	new_bubble.name = "bubble%d" % bubbles_spawned
	new_bubble.start()
	

func handle_pop(stats: BubbleStats) -> void:
	score += stats.value
	prints("score is now", score)
	
	%Score.text = "SCORE: %s" % score

	if self.score_twn:
		self.score_twn.kill()

	if stats.value > 0:
		%Score.modulate = Color.GREEN
		self.score_twn = create_tween()
		self.score_twn.tween_property(%Score, "modulate", Color.WHITE, 1)
	elif stats.value < 0:
		%Score.modulate = Color.GOLD
		self.score_twn = create_tween()
		self.score_twn.tween_property(%Score, "modulate", Color.WHITE, 1)


func handle_escape(bubble: Bubble) -> void:
	prints("adjust lives:", bubble.stats.value)
	var adjusted_penalty = bubble.stats.value / 5.0
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
	
	if self.score < ghost_tower.cost:
		return
	
	self.score -= ghost_tower.cost
	
	var new_tower = ghost_tower.scene.instantiate()
	prints("spawning", new_tower.name, "at", tower_pos)
	
	%Map.add_child(new_tower)
	new_tower.position = tower_pos
	
	%Toolbar.last_selected = null
	
	ghost_tower.queue_free()
