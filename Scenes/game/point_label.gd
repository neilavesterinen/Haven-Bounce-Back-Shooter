extends Node

@export var label: Label3D


func _ready() -> void:
	_on_points_changed(GameState.points)
	GameState.points_changed.connect(_on_points_changed)


func _on_points_changed(new_points: int) -> void:
	label.text = str(new_points).pad_zeros(9)
