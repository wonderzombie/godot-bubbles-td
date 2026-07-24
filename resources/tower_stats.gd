class_name TowerStats extends Resource

enum Ty {
	DOG_I,
}

static var all_stats = {
	Ty.DOG_I: load("res://resources/dog_tower_i.tres")
}

@export var detection_radius: float # = 36.0
@export var attack_cooldown: float # = 2.05
@export var hits_per_rock: int # = 1
@export var rock_range: float # = 12 * 4

func apply(other: TowerStats) -> void:
	if other.detection_radius > 0:
		self.detection_radius = other.detection_radius
	if other.attack_cooldown > 0:
		self.attack_cooldown = other.attack_cooldown
	if other.hits_per_rock > 0:
		self.hits_per_rock = other.hits_per_rock
	if other.rock_range > 0:
		self.rock_range = other.rock_range

static func empty() -> TowerStats:
	return TowerStats.new()
