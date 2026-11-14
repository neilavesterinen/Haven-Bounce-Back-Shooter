extends CharacterBody2D
class_name Enemy

var health := 1
var player := get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	pass
