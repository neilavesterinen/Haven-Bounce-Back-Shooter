class_name NodeAndAmount
extends Resource

@export var node: PackedScene
@export var amount: int = 1


func duplicate_with_count() -> Resource:
	var node_and_count := NodeAndAmount.new()

	node_and_count.node = node
	node_and_count.amount = amount

	return node_and_count
