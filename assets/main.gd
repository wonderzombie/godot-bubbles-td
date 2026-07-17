extends Node2D

var bubbles = [];
var score = 0;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Toolbar.selected.connect(selected_tower)


func _unhandled_key_input(event: InputEvent) -> void:
	if !event.is_action_pressed("next_round"):
		return
	
	var start_wp: Marker2D = %Waypoints.get_child(0);
	var end_wp: Marker2D = %Waypoints.get_child(-1);
	prints("start is %s and end is %s" % [start_wp, end_wp])
	
	var new_bubble = %Bubble.duplicate();
	
	new_bubble.position = start_wp.position;
	new_bubble.destination = end_wp.position;
	
	%Map.add_child(new_bubble);
	self.bubbles.push_front(new_bubble);
	
	new_bubble.pop.connect(balloon_popped)
	new_bubble.visible = true;
	new_bubble.start()
	

func balloon_popped(award: int) -> void:
	score += award
	prints("score is now", score)
	%Score.text = "SCORE: %s" % score
	
	
func selected_tower(sprite: Sprite2D) -> void:
	match sprite.name:
		"DogButton1":
			pass

func _input(event) -> void:
	pass
