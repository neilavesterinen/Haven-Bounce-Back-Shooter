class_name Wave
extends Resource

@export var nodes_and_amounts: Array[NodeAndAmount]

@export var spawn_delay_range: Vector2 = Vector2.ONE
@export var spawn_group_size_range: Vector2i = Vector2i.ONE


func duplicate_nodes_and_amounts() -> Array[NodeAndAmount]:
	var nodes_and_amounts_duplicate: Array[NodeAndAmount]

	for node_and_amount in nodes_and_amounts:
		nodes_and_amounts_duplicate.append(node_and_amount.duplicate_with_count())

	return nodes_and_amounts_duplicate
