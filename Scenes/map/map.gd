extends Node2D

## Map bounds for random building placement. Kept inside the boundary walls so
## buildings do not clip the navigation region outline.
const MAP_HALF_EXTENT := 2500.0

## Number of placement attempts per building before skipping it.
const PLACEMENT_ATTEMPTS := 150

## Keep this radius around world origin clear so the player never spawns inside a building.
const SPAWN_CLEAR_RADIUS := 400.0
const NAV_CELL_SIZE := 16.0
const NAV_AGENT_RADIUS := 32.0

@onready var spawnregion: NavigationRegion2D = $spawnreg
@onready var nav_region: NavigationRegion2D = $Navigation

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Footprints of already placed buildings, used for cheap overlap checks without
## waiting for physics frames.
var _placed_footprints: Array[Footprint] = []

@export var random_buildings: Array[PackedScene] = [
	preload("res://Scenes/map/spawnables/box.tscn"),
	preload("res://Scenes/map/spawnables/wall.tscn"),
	preload("res://Scenes/map/spawnables/square.tscn"),
	preload("res://Scenes/map/spawnables/tri.tscn")
]


class Footprint:
	var shape: Shape2D
	var transform: Transform2D

	func _init(p_shape: Shape2D, p_transform: Transform2D) -> void:
		shape = p_shape
		transform = p_transform


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Map.gd ready!")
	generate_map()


func generate_map() -> void:
	if random_buildings.is_empty():
		print("empty random buildings")
		return

	var start_msec := Time.get_ticks_msec()
	rng.randomize()

	# This region has a full-map navigation polygon but no building children, so
	# it would let enemies path straight through the generated buildings. The
	# spawner only uses its own `spawn_area`, not this region.
	if spawnregion:
		spawnregion.enabled = false

	var randcount: int = rng.randi_range(125, 150)
	var placed_count := 0

	for _i in randcount:
		var random_scene: PackedScene = random_buildings[
			rng.randi_range(0, random_buildings.size() - 1)
		]
		var building := random_scene.instantiate() as Node2D
		if building == null:
			continue
		nav_region.add_child(building)

		var placed := false
		for _attempt in PLACEMENT_ATTEMPTS:
			var random_pos := Vector2(
				rng.randf_range(-MAP_HALF_EXTENT, MAP_HALF_EXTENT),
				rng.randf_range(-MAP_HALF_EXTENT, MAP_HALF_EXTENT),
			)
			if random_pos.length_squared() < SPAWN_CLEAR_RADIUS * SPAWN_CLEAR_RADIUS:
				continue

			building.position = random_pos
			# Set the rotation instead of calling rotate(), otherwise failed
			# attempts keep adding rotation on top of each other.
			building.rotation = rng.randf_range(0.0, TAU)

			var footprint := _get_footprint(building)
			if footprint == null:
				continue
			if _overlaps_placed(footprint):
				continue

			_placed_footprints.append(footprint)
			placed = true
			placed_count += 1
			break

		if not placed:
			building.free()

	_bake_navigation()

	print(
		"Map generated: %d buildings in %d ms"
		% [placed_count, Time.get_ticks_msec() - start_msec]
	)


func _get_footprint(building: Node2D) -> Footprint:
	var hitbox := building.get_node_or_null("Hitbox") as Area2D
	if hitbox == null:
		return null

	var shape_node := hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null or shape_node.shape == null:
		return null

	return Footprint.new(shape_node.shape, shape_node.global_transform)


func _overlaps_placed(footprint: Footprint) -> bool:
	for placed in _placed_footprints:
		if footprint.shape.collide(footprint.transform, placed.shape, placed.transform):
			return true
	return false


func _bake_navigation() -> void:
	if nav_region == null:
		return

	var navigation_polygon := nav_region.navigation_polygon
	if navigation_polygon == null:
		return

	navigation_polygon.cell_size = NAV_CELL_SIZE
	navigation_polygon.agent_radius = NAV_AGENT_RADIUS
	# Every building has static collision shapes, so parsing only those avoids
	# duplicate edges from the matching Polygon2D visuals.
	navigation_polygon.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS

	# Bake in the background so the game does not freeze while the navigation
	# mesh is rebuilt to go around the generated buildings.
	nav_region.bake_navigation_polygon(true)
	while nav_region.is_baking():
		await get_tree().process_frame
