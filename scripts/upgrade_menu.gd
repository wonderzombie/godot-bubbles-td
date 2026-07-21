extends Control

signal clicked(tower: TowerDog, row: UpgradeRow)

@onready var rows: Array = get_node(^"VBoxContainer").get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for it in rows:
		var row := it as UpgradeRow
		if !row:
			push_error("invalid row: %s" % it)
			continue


	self.visibility_changed.connect(on_visibility_changed)

func on_button_down(tower: TowerDog, clicked_row: UpgradeRow) -> void:
	self.clicked.emit(tower, clicked_row)

func on_visibility_changed() -> void:
	if !self.visible:
		for it in rows:
			var row := it as UpgradeRow
			if !row:
				push_error("invalid row: %s" % it)
				continue

			row.reset()

			if row.check_box.button_down.is_connected(self.on_button_down):
				row.check_box.button_down.disconnect(self.on_button_down)

# TODO: avoid using TowerDog here. We need TowerDog so when we emit `clicked()` we can pass the tower to the handler.
func bind_to(the_tower: TowerDog) -> void:
	prints("binding to tower", the_tower)
	for it in rows:
		var row := it as UpgradeRow
		if !row:
			push_error("invalid row: %s" % it)
			continue

		var upgrade = the_tower.upgrades.get_nth(row.get_index())
		if !upgrade:
			push_error("no upgrade found for row %s" % row.get_index())
			continue

		var enabled = the_tower.enabled_upgrades.get(upgrade.title, false)
		row.bind_to(upgrade, enabled)

		row.check_box.button_down.connect(func() -> void:
			self.on_button_down(the_tower, row))
