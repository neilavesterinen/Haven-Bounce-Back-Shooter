extends Node

signal points_changed(new_points: int)

var points: int = 10:
	set(value):
		points = value
		points_changed.emit(value)
