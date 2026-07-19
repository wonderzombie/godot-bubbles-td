extends Node2D

@export var score := 0
@export var lives := 60

var ghost_tower: DogButton
var bubbles_spawned: int
var score_twn: Tween
var lives_twn: Tween
var waypoints: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Toolbar.selected.connect(selected_tower)
	%Lives.text = "LIVES: %d" % lives
	%Messages.text = ""
	
	for node in get_tree().get_nodes_in_group(&"towers"):
		var tower := node as TowerDog
		if !tower:
			continue
		
		tower.clicked.connect(func(): _tower_clicked(tower))
	
	%UpgradeMenu.clicked.connect(on_upgrade_clicked)
	
	self.waypoints = get_tree().get_nodes_in_group(&"waypoints")

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
	
	# Don't bother spawning anything if no waypoints found
	var waypoints_group = get_tree().get_nodes_in_group(&"waypoints")
	assert(!waypoints_group.is_empty(), "waypoints group was empty!")
	

	var new_bubble: Bubble = %Bubble.duplicate();
	new_bubble.set_stats(stats)
	%Map.add_child(new_bubble);
	
	new_bubble.pop.connect(handle_pop)
	new_bubble.escaped.connect(handle_escape)
	
	bubbles_spawned += 1
	new_bubble.name = "bubble%d" % bubbles_spawned
	new_bubble.start(self.waypoints)	

func handle_pop(bubble: Bubble) -> void:
	score += bubble.stats.value
	bubble.stop()
	bubble.set_active(false)
	bubble.queue_free()
	prints("score is now", score)
	
	%Score.text = "SCORE: %s" % score

	if self.score_twn:
		self.score_twn.kill()

	if bubble.stats.value > 0:
		%Score.modulate = Color.GREEN
		self.score_twn = create_tween()
		self.score_twn.tween_property(%Score, "modulate", Color.WHITE, 1)
	elif bubble.stats.value < 0:
		%Score.modulate = Color.GOLD
		self.score_twn = create_tween()
		self.score_twn.tween_property(%Score, "modulate", Color.WHITE, 1)


func handle_escape(bubble: Bubble) -> void:
	prints("adjust lives:", bubble.stats.penalty)
	lives -= bubble.stats.penalty

	%Lives.text = "LIVES: %d" % lives
	%Lives.modulate = Color.RED
	
	if self.lives_twn:
		self.lives_twn.kill()
	
	self.lives_twn = create_tween()
	self.lives_twn.tween_property(%Lives, "modulate", Color.WHITE, 1)
	
	bubble.stop()
	bubble.queue_free()

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
	
	var new_tower: TowerDog = ghost_tower.scene.instantiate()
	prints("spawning", new_tower.name, "at", tower_pos)
	
	%Map.add_child(new_tower)
	new_tower.position = tower_pos
	new_tower.clicked.connect(func(): _tower_clicked(new_tower))

	%Toolbar.last_selected = null
	
	ghost_tower.queue_free()

func _tower_clicked(tower: TowerDog) -> void:
	prints("tower clicked:", tower)
	%UpgradeMenu.position = tower.global_position + Vector2.UP * 8 + Vector2.RIGHT * 8
	%UpgradeMenu.visible = !%UpgradeMenu.visible
	
func on_upgrade_clicked(upgrade_row: UpgradeRow) -> void:
	prints("upgrade clicked", upgrade_row)
	if score < upgrade_row.cost:
		prints("and rejected")
		%Messages.add_message("can't afford %d" % upgrade_row.cost, Color.RED)
		%UpgradeMenu.upgrade_rejected(upgrade_row)
	
	prints("and approved")
	%UpgradeMenu.upgrade_approved(upgrade_row)
		
