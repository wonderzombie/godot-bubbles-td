class_name Toolbar extends Node2D

signal purchased(sprite: DogButton)

var last_selected: DogButton

@onready var _message_label: Label = %Messages

func _unhandled_input(event) -> void:
	if last_selected:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var score = GameService.score

		for it in get_children():
			var button := it as DogButton
			if not button:
				continue
			var local_position = button.get_local_mouse_position()
			if button.get_rect().has_point(local_position):
				if button.cost > score:
					prints("can't afford cost", button.cost, "with score", score)
					_message_label.text = "tower costs %d but you have %d" % [button.cost, score]
					_message_label.modulate = Color.RED
					return
				_valid_tower_clicked(button)
				get_viewport().set_input_as_handled()
				return

func _valid_tower_clicked(tower_button: DogButton) -> void:
	prints("clicked", tower_button)
	self.last_selected = tower_button
	purchased.emit(tower_button)


func reset() -> void:
	self.last_selected = null
