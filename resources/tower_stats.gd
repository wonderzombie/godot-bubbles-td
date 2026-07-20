class_name TowerStats extends Resource

enum Ty {
	DOG_I,
}

static var all_stats = {
	Ty.DOG_I: load("res://resources/dog_tower_i.tres")
}

@export var detection_radius: float = 36.0
@export var attack_cooldown: float = 2.05
@export var hits_per_rock: int = 2
@export var rock_range: float = 12 * 4
