extends Node

@export var map: PackedScene
@export var playersc: PackedScene

var points: int = 0
var points_display_pending: int = 0
var defaultpt: int = 000000000
var stage: int = 1

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


# game start
func _ready() -> void:
	stage = 1
	stagetext.text = int_to_roman(1)

	# spawn map
	var mapc := map.instantiate()
	add_child(mapc)

	if playersc != null:
		var playerc := playersc.instantiate()
		add_child(playerc)


func refresh_points(new_points: int) -> void:
	pointstext.text = str(new_points).pad_zeros(9)
