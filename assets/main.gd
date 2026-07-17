extends Node2D

var bubbles = [];
@export var score = 0;
var bubbles_spawned = 0;

var ghost_tower: DogButton;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Toolbar.selected.connect(selected_tower)



func _unhandled_key_input(event: InputEvent) -> void:
	var color = Color.TRANSPARENT
	if event.is_action_pressed("next_round"):
		pass
	elif event.is_action_pressed("first_balloon"):
		color = Color.RED
	elif event.is_action_pressed("second_balloon"):
		color = Color.BLUE
	elif event.is_action_pressed("third_balloon"):
		color = Color.YELLOW
	else:
		return
		
	var start_wp: Marker2D = %Waypoints.get_child(0);
	var end_wp: Marker2D = %Waypoints.get_child(-1);
	prints("start is %s and end is %s" % [start_wp, end_wp])
	
	var new_bubble = %Bubble.duplicate();
	
	new_bubble.position = start_wp.position;
	new_bubble.destination = end_wp.position;
	
	%Map.add_child(new_bubble);
	self.bubbles.push_front(new_bubble);
	
	new_bubble.pop.connect(adjust_score)
	new_bubble.visible = true;
	bubbles_spawned += 1
	new_bubble.name = "bubble%d" % bubbles_spawned
	new_bubble.start(color)
	

func adjust_score(award: int) -> void:
	score += award
	prints("score is now", score)
	%Score.text = "SCORE: %s" % score
	
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
