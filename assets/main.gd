extends Node2D

var bubbles = [];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

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
	
	new_bubble.visible = true;
	new_bubble.start()
