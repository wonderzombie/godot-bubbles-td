class_name UpgradeRow extends HBoxContainer

@onready var check_box: CheckBox = get_node(^"CheckBox")
@onready var cost_label: Label = get_node(^"Cost")
@onready var upgrade_name = self.check_box.text

var checked: bool
var cost: int = 10

func set_cost(new_cost: int) -> void:
	self.cost_label.text = "$&d" % new_cost
		
