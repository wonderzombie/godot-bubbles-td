class_name BubbleStats extends Resource

enum Ty {
	RED,
	BLUE,
	GREEN
}

@export var color: Color = Color.RED
@export var speed: float = 20
@export var max_hits: int = 1
@export var value: int = 5

static var STATS = {
	Ty.RED: load("res://resources/red_bubble.tres"),
	Ty.BLUE: load("res://resources/blue_bubble.tres"),
	Ty.GREEN: load("res://resources/green_bubble.tres")
}
