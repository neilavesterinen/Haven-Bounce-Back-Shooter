extends Node

enum GameStates {
	SHOP,
	GAME,
	DIE,
}

@export var wave_spawner: WaveSpawner

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
	_on_wave_changed(0)

	GameState.points = 0

	wave_spawner.wave_changed.connect(_on_wave_changed)


func _on_wave_changed(new_wave: int) -> void:
	stagetext.text = int_to_roman(new_wave + 1)
