class_name WaveNodeFreeTracker
extends Node

var owner_wave_spawner: WaveSpawner
var test: int


func _ready() -> void:
	tree_exited.connect(_on_tree_exited)


func _on_tree_exited() -> void:
	owner_wave_spawner.spawned_node_freed()
