class_name UpgradeRow extends HBoxContainer

var cost: int:
	get(): return cost_label.text.to_int() if cost_label else 0

var title: String:
	get(): return check_box.text if check_box else ""

@onready var check_box: CheckBox = get_node(^"CheckBox")
@onready var cost_label: Label = get_node(^"Cost")

func bind_to(upgrade: TowerUpgrade, enabled: bool) -> void:
	prints("binding row to upgrade", upgrade.title, "enabled:", enabled)
	self.check_box.set_deferred("text", upgrade.title)
	self.cost_label.set_deferred("text", "%d" % upgrade.cost)

	if enabled:
		prints("upgrade already enabled:", upgrade.title)
		mark_upgrade_approved()

func mark_upgrade_approved() -> void:
	self.check_box.set_pressed_no_signal(true)
	self.check_box.disabled = true

func mark_upgrade_rejected() -> void:
	self.check_box.set_pressed_no_signal(false)

func reset() -> void:
	self.check_box.set_pressed_no_signal(false)
	self.check_box.text = ""
	self.cost_label.text = ""
	self.check_box.disabled = false
