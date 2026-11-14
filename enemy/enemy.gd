extends CharacterBody2D
class_name Enemy

var MAX_HEALTH := 5

var health := MAX_HEALTH
var player : Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	modulate.a = 1.0 / MAX_HEALTH * health
	
	if health == 0:
		queue_free()
