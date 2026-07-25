class_name DogButton extends Sprite2D

@export_file var tower_file;
@export var cost: int = 15

@onready var scene := load(tower_file)
@onready var label: Label = get_node(^"CostLabel")
@onready var default_alpha: float = self.self_modulate.a

func _ready() -> void:
	label.text = "%d" % cost
	self.self_modulate.a = default_alpha

func _unhandled_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseMotion

	if !mouse_event:
		return

	if self.get_rect().has_point(get_local_mouse_position()):
		self.self_modulate.a = 1.0
	elif self.self_modulate.a != default_alpha:
		self.self_modulate.a = default_alpha
