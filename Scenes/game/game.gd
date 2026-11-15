extends Node

@export var map: PackedScene
@export var playersc: PackedScene

var points: int = 0
var points_display_pending: int = 0
var defaultpt: int = 000000000
var stage: int = 1

@export var map: PackedScene
@export var playersc: PackedScene
@export var enemysc: PackedScene

enum GameStates {
	SHOP,
	GAME,
	DIE
}
var game_state: GameStates = GameStates.GAME

@onready var pointstext: Label3D = $CanvasLayer/PointsT/SubViewport/Label3D
@onready var stagetext: Label3D = $CanvasLayer/StageT/SubViewport2/Label3D

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

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


func random_no_collide_position() -> Vector2:
	return Vector2(rng.randi_range(-3000,3000), rng.randi_range(-3000,3000))

func spawn_botwave(count: int) -> void:
	for i in count:
		var randloc: Vector2 = random_no_collide_position()
		var ene: Enemy = enemysc.instantiate()
		ene.position = randloc
		add_child(ene)

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
	
	spawn_botwave(50)
	
	


func refresh_points(new_points: int) -> void:
	pointstext.text = str(new_points).pad_zeros(9)
