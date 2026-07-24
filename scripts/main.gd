extends Node2D

@export var start_score := 15
@export var start_lives := 60

var waypoints: Array[Node]
var bubbles_spawned: int

var _ghost_tower: DogButton
var _score_twn: Tween
var _lives_twn: Tween
var _selected_tower: TowerDog

@onready var _upgrade_menu: UpgradeMenu = %UpgradeMenu
@onready var _toolbar: Toolbar = %Toolbar
@onready var _messages: Label = %Messages
@onready var _score_label: Label = %Score
@onready var _lives_label: Label = %Lives

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameService.score_changed.connect(self.on_score_changed)
	GameService.lives_changed.connect(self.on_lives_changed)
	GameService.start_game(start_score, start_lives)

	_toolbar.purchased.connect(on_tower_purchased)

	_messages.text = ""

	for node in get_tree().get_nodes_in_group(&"towers"):
		var placed_tower := node as TowerDog
		if !placed_tower:
			continue

		placed_tower.clicked.connect(func(): _tower_clicked(placed_tower))

	_upgrade_menu.clicked.connect(on_upgrade_clicked)

	self.waypoints = get_tree().get_nodes_in_group(&"waypoints")

func on_score_changed(new_score: int) -> void:
	_score_label.set_deferred("text", "%d" % new_score)

func on_lives_changed(new_lives: int) -> void:
	_lives_label.set_deferred("text", "%d" % new_lives)

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
	assert(!self.waypoints.is_empty(), "waypoints group was empty!")

	var new_bubble: Bubble = %Bubble.duplicate();
	new_bubble.set_stats(stats)
	%Map.add_child(new_bubble);
	new_bubble.add_to_group(&"bubbles")

	new_bubble.pop.connect(handle_pop)
	new_bubble.escaped.connect(handle_escape)

	bubbles_spawned += 1
	new_bubble.name = "bubble%d" % bubbles_spawned
	new_bubble.start(self.waypoints)

func handle_pop(bubble: Bubble) -> void:
	bubble.stop()
	bubble.set_active(false)
	bubble.queue_free()
	prints("score is now", GameService.score)

	if self._score_twn:
		self._score_twn.kill()

	GameService.add_score(bubble.stats.value)
	if bubble.stats.value > 0:
		_score_label.modulate = Color.GREEN
		self._score_twn = create_tween()
		self._score_twn.tween_property(_score_label, "modulate", Color.WHITE, 1)
	elif bubble.stats.value < 0:
		_score_label.modulate = Color.GOLD
		self._score_twn = create_tween()
		self._score_twn.tween_property(_score_label, "modulate", Color.WHITE, 1)

func handle_escape(bubble: Bubble) -> void:
	prints("adjust lives:", bubble.stats.penalty)
	GameService.add_lives(-bubble.stats.penalty)

	self._lives_label.text = "LIVES: %d" % GameService.lives
	self._lives_label.modulate = Color.RED

	if self._lives_twn:
		self._lives_twn.kill()

	self._lives_twn = create_tween()
	self._lives_twn.tween_property(_lives_label, "modulate", Color.WHITE, 1)

	bubble.stop()
	bubble.queue_free()

func on_tower_purchased(sprite: DogButton) -> void:
	match sprite.name:
		"DogButton1":
			prints("selected", self._ghost_tower)
			self._ghost_tower = sprite.duplicate()
			self.add_child(_ghost_tower)
			_ghost_tower.add_to_group(&"towers")
			self._ghost_tower.position = self.get_local_mouse_position()

func _input(event) -> void:
	if !self._ghost_tower:
		return

	var map_pos = %Map.get_local_mouse_position()
	var cell_pos = %Map.local_to_map(map_pos)
	var tower_pos = %Map.map_to_local(cell_pos)

	if event is InputEventMouseMotion:
		self._ghost_tower.position = tower_pos

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var tile_data: TileData = %Map.get_cell_tile_data(cell_pos)
		var is_path = tile_data.get_custom_data("path") as bool
		if is_path:
			_messages.add_message("can't place tower on path", Color.RED)
			prints("can't place tower on path at", cell_pos)
			return

		_maybe_place_tower(tower_pos)
		get_viewport().set_input_as_handled()

func _maybe_place_tower(tower_pos):
	prints("clicked:", self._ghost_tower.position)

	if GameService.score < _ghost_tower.cost:
		%Messages.add_message("can't afford %d" % _ghost_tower.cost, Color.RED)
		prints("can't afford tower", _ghost_tower.name,
			"cost:", _ghost_tower.cost, "score:", GameService.score)
		return

	GameService.add_score(-_ghost_tower.cost)

	var new_tower: TowerDog = _ghost_tower.scene.instantiate()
	prints("spawning", new_tower.name, "at", tower_pos)

	%Map.add_child(new_tower)
	new_tower.position = tower_pos
	get_viewport().set_input_as_handled()
	new_tower.clicked.connect(func(): _tower_clicked(new_tower))

	%Toolbar.reset()

	_ghost_tower.queue_free()

func _tower_clicked(tower: TowerDog) -> void:
	prints("tower clicked:", tower)
	self._upgrade_menu.position = tower.global_position + Vector2.UP * 8 + Vector2.RIGHT * 8

	if self._upgrade_menu.visible:
		self._selected_tower = null
	else:
		self._upgrade_menu.bind_to(tower)
		self._selected_tower = tower

	self._upgrade_menu.visible = !self._upgrade_menu.visible


func on_upgrade_clicked(upgrade_row: UpgradeRow) -> void:
	prints("upgrade clicked", upgrade_row)

	# TODO: this may be unnecessary since a disabled checkbox cannot be clicked, but just in case, we
	# check here too.
	if GameService.score < upgrade_row.cost:
		upgrade_row.mark_upgrade_rejected()
		%Messages.add_message("can't afford %d" % upgrade_row.cost, Color.RED)
		return

	prints("and approved", upgrade_row.title)
	upgrade_row.mark_upgrade_approved()
	_selected_tower.do_upgrade(upgrade_row.title)
	GameService.add_score(-upgrade_row.cost)
