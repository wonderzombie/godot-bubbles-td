class_name UpgradeRow extends HBoxContainer

@onready var check_box: CheckBox = get_node(^"CheckBox")
@onready var cost_label: Label = get_node(^"Cost")
@onready var upgrade_name = self.check_box.text

var cost: int = 10:
	set(c):
		cost = c
		self.cost_label.set_deferred("text", "$&d" % c)
		
