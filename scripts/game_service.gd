extends Node

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)

var score: int
var lives: int

func start_game(start_score: int, start_lives: int) -> void:
	self.score = 0
	self.add_score(start_score)
	self.lives = 0
	self.add_lives(start_lives)

func add_score(amt: int) -> int:
	self.score += amt
	score_changed.emit(self.score)
	return self.score

func add_lives(amt: int) -> int:
	self.lives += amt
	lives_changed.emit(self.lives)
	return self.lives
