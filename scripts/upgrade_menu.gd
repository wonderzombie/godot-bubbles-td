extends Control

signal clicked(row: UpgradeRow)

@onready var rows: Array = get_node(^"VBoxContainer").get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for it in rows:
		var row := it as UpgradeRow
		if !row:
			push_error("invalid row: %s" % it)
			continue

		row.check_box.button_down.connect(
			func(): on_button_down(row))

func on_button_down(clicked_row: UpgradeRow) -> void:
	self.clicked.emit(clicked_row)

func upgrade_approved(clicked_row: UpgradeRow) -> void:
	prints("disabled:", clicked_row)
	clicked_row.check_box.set_pressed_no_signal(true)
	clicked_row.check_box.disabled = true

func upgrade_rejected(clicked_row: UpgradeRow) -> void:
	clicked_row.check_box.set_pressed_no_signal(false)
