extends SceneTree


func _initialize() -> void:
	var map_scene := load("res://Scenes/map/map.tscn") as PackedScene
	var map := map_scene.instantiate() as Node2D
	root.add_child(map)

	for _i in 600:
		await process_frame
		var region_node := map.get_node("Navigation") as NavigationRegion2D
		if not region_node.is_baking():
			break

	var region := map.get_node("Navigation") as NavigationRegion2D
	var polygon := region.navigation_polygon
	print("NAV polygons: ", polygon.get_polygon_count(), " vertices: ", polygon.get_vertices().size())

	var vertices := polygon.get_vertices()
	var triangles: Array[PackedVector2Array] = []
	for i in polygon.get_polygon_count():
		var indices := polygon.get_polygon(i)
		var tri := PackedVector2Array()
		for index in indices:
			tri.append(vertices[index])
		triangles.append(tri)

	var checked := 0
	var failures := 0
	for child in region.get_children():
		var interior := _interior_point(child)
		if not interior.is_finite():
			continue
		var covered := false
		for tri in triangles:
			if Geometry2D.is_point_in_polygon(interior, tri):
				covered = true
				break
		checked += 1
		if covered:
			failures += 1
			print("FAIL ", child.scene_file_path.get_file(), " interior covered at ", interior)
		if checked >= 25:
			break

	print("NAV check: ", checked, " buildings sampled, ", failures, " covered by navmesh")

	quit()


func _interior_point(building: Node) -> Vector2:
	for body in building.get_children():
		if body is StaticBody2D:
			for shape_child in body.get_children():
				if shape_child is CollisionShape2D:
					var cs := shape_child as CollisionShape2D
					return cs.global_transform * cs.shape.get_rect().get_center()
				if shape_child is CollisionPolygon2D:
					var cp := shape_child as CollisionPolygon2D
					var points := cp.polygon
					var centroid := Vector2.ZERO
					for p in points:
						centroid += p
					centroid /= points.size()
					return cp.global_transform * centroid
	return Vector2.INF
