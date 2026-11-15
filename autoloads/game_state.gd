extends Node

signal points_changed(new_points: int)

var points: int = 0:
	set(value):
		points = value
		points_changed.emit(value)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		points += 123
