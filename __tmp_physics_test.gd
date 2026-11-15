extends Node


func _ready() -> void:
	for scene_path in [
		"res://Scenes/map/spawnables/box.tscn",
		"res://Scenes/map/spawnables/wall.tscn",
		"res://Scenes/map/spawnables/square.tscn",
		"res://Scenes/map/spawnables/tri.tscn",
	]:
		var scene := load(scene_path) as PackedScene
		var building := scene.instantiate() as Node2D
		add_child(building)
		building.global_position = Vector2.ZERO
		await get_tree().physics_frame
		await get_tree().physics_frame

		var bodies := 0
		var hits_enemy := 0
		var hits_orb := 0
		for body in building.get_children():
			if body is not StaticBody2D:
				continue
			bodies += 1
			for child in body.get_children():
				var point := Vector2.INF
				if child is CollisionShape2D:
					var cs := child as CollisionShape2D
					point = cs.global_transform * cs.shape.get_rect().get_center()
				elif child is CollisionPolygon2D:
					var cp := child as CollisionPolygon2D
					var sum := Vector2.ZERO
					for p in cp.polygon:
						sum += p
					point = cp.global_transform * (sum / cp.polygon.size())

				if not point.is_finite():
					continue

				var query := PhysicsPointQueryParameters2D.new()
				query.position = point
				query.collision_mask = 3
				if not get_viewport().world_2d.direct_space_state.intersect_point(query).is_empty():
					hits_enemy += 1
				query.collision_mask = 2147483648
				if not get_viewport().world_2d.direct_space_state.intersect_point(query).is_empty():
					hits_orb += 1

		print(
			scene_path.get_file(), ": bodies=", bodies,
			" enemy_hits=", hits_enemy, " orb_hits=", hits_orb,
		)

		building.queue_free()
		await get_tree().physics_frame

	get_tree().quit()
