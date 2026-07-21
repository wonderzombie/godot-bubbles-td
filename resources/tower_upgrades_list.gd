class_name TowerUpgradesList extends Resource

@export var upgrade_one: TowerUpgrade
@export var upgrade_two: TowerUpgrade
@export var upgrade_three: TowerUpgrade

func get_nth(index: int) -> TowerUpgrade:
	match index:
		0: return upgrade_one
		1: return upgrade_two
		2: return upgrade_three
		_: return
