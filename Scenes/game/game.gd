extends Node

enum GameStates {
	SHOP,
	GAME,
	DIE,
}

@export var wave_spawner: WaveSpawner

@onready var pointstext: Label3D = $CanvasLayer/PointsT/SubViewport/Label3D
@onready var stagetext: Label3D = $CanvasLayer/StageT/SubViewport2/Label3D


static func int_to_roman(num: int) -> String:
	if num <= 0 or num > 3999:
		return str(num) # Standard Roman numerals only cover 1 to 3999

	var values: Array[int] = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
	var symbols: Array[String] = [
		"M",
		"CM",
		"D",
		"CD",
		"C",
		"XC",
		"L",
		"XL",
		"X",
		"IX",
		"V",
		"IV",
		"I",
	]

	var result: String = ""
	for i in range(values.size()):
		while num >= values[i]:
			num -= values[i]
			result += symbols[i]

	return result


func _ready() -> void:
	_on_points_changed(0)
	_on_wave_changed(0)

	GameState.points_changed.connect(_on_points_changed)
	wave_spawner.wave_changed.connect(_on_wave_changed)


func _on_points_changed(new_points: int) -> void:
	pointstext.text = str(new_points).pad_zeros(9)


func _on_wave_changed(new_wave: int) -> void:
	stagetext.text = int_to_roman(new_wave + 1)
