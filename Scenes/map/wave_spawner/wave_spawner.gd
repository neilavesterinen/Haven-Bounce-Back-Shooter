@tool
class_name WaveSpawner
extends Node2D

@export var waves: Array[Wave]

@export var spawn_pos_clearance_check_shape: Shape2D
@export var spawn_area: Rect2:
	set(value):
		spawn_area = value
		queue_redraw()

@export var spawned_node_parent: Node2D

var nodes_left_to_spawn: Array[NodeAndAmount]
var nodes_left_alive: int

var wave_number: int
# For some reasons unknown, having this as 0 and immediately spwaning nodes breaks the freeing tracking
var spawn_cooldown: float = 1.0

var _clearance_check_query: PhysicsShapeQueryParameters2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_clearance_check_query = PhysicsShapeQueryParameters2D.new()
	_clearance_check_query.shape = spawn_pos_clearance_check_shape

	wave_number = -1
	new_wave()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if nodes_left_to_spawn.is_empty():
		if (
			nodes_left_alive != 0 or waves.size() == 0
			or waves[wave_number].nodes_and_amounts.size() == 0
		):
			return

		new_wave()

	spawn_cooldown -= delta
	if spawn_cooldown > 0:
		return

	var wave := waves[wave_number]
	spawn_from_wave(wave)

	spawn_cooldown = randf_range(wave.spawn_delay_range.x, wave.spawn_delay_range.y)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	draw_rect(spawn_area, Color.RED, false)


func spawn_from_wave(wave: Wave) -> void:
	var amount := randi_range(wave.spawn_group_size_range.x, wave.spawn_group_size_range.y)

	for i in amount:
		var node_i_to_spawn := randi_range(0, nodes_left_to_spawn.size() - 1)

		var spawned_node: Node2D = nodes_left_to_spawn[node_i_to_spawn].node.instantiate()
		spawned_node_parent.add_child(spawned_node)

		var free_tracker := WaveNodeFreeTracker.new()
		free_tracker.owner_wave_spawner = self
		spawned_node.add_child(free_tracker)

		var spawn_pos := find_valid_spawn_pos()
		spawned_node.global_position = spawn_pos
		nodes_left_alive += 1

		nodes_left_to_spawn[node_i_to_spawn].amount -= 1
		if nodes_left_to_spawn[node_i_to_spawn].amount == 0:
			nodes_left_to_spawn.remove_at(node_i_to_spawn)

		if nodes_left_to_spawn.is_empty():
			return


func new_wave() -> void:
	if wave_number + 1 < waves.size():
		wave_number += 1

	nodes_left_to_spawn = waves[wave_number].duplicate_nodes_and_amounts()


func find_valid_spawn_pos() -> Vector2:
	for _i in 100:
		var candidate_pos := Vector2(
			randf_range(0, spawn_area.size.x + spawn_area.position.x),
			randf_range(0, spawn_area.size.y + spawn_area.position.y),
		)

		_clearance_check_query.transform = Transform2D(0, to_global(candidate_pos))

		if get_world_2d().direct_space_state.intersect_shape(_clearance_check_query, 1).is_empty():
			return candidate_pos

	return Vector2.ZERO


func spawned_node_freed() -> void:
	nodes_left_alive -= 1
