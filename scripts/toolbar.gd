class_name Toolbar extends Node2D

signal selected(sprite: DogButton)

var last_selected: DogButton

func _unhandled_input(event) -> void:
	if last_selected:
		return


	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var score = get_parent().score

		for it in get_children():
			var button := it as DogButton
			if not button:
				continue
			var local_position = button.get_local_mouse_position()
			if button.get_rect().has_point(local_position):
				if button.cost > score:
					prints("can't afford cost", button.cost, "with score", score)
					%Messages.add_message("tower costs %d but you have %d" % [button.cost, score], Color.RED)
					return
				prints(event)
				_clicked(button)
				get_viewport().set_input_as_handled()
				return

func _clicked(it: DogButton) -> void:
	prints("clicked", it)
	self.last_selected = it
	selected.emit(it)
