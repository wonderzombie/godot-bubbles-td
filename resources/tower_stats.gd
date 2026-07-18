class_name TowerStats extends Resource

@export var detection_radius: float = 36.0
@export var attack_cooldown: float = 2.05
@export var bubble_pops_per_rock: int = 2

enum Ty {
	DOG_I,
}

static var STATS = {
	Ty.DOG_I: load("res://resources/dog_tower_i.tres")
}
