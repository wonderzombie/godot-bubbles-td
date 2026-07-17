class_name Toolbar extends Node2D

signal selected(sprite: Sprite2D)

var last_selected: Sprite2D

func _input(event) -> void:
	#prints("unhandled input", event)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		for it in get_children():
			var button := it as Sprite2D
			var local_position = button.get_local_mouse_position()
			if button.get_rect().has_point(local_position):
				_clicked(button)
				return

func _clicked(it: Sprite2D) -> void:
	prints("clicked", it)
	self.last_selected = it
	selected.emit(it)
