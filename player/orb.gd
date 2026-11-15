extends RigidBody2D
class_name Orb

var player: Player

var enemies: Array

var target_node: Node2D

var SPEED := 10.0

var bouncing_back := false

var speed_increase_time := 0.0

var bounces := 2


func _process(delta: float) -> void:
	if bouncing_back:
		speed_increase_time += delta
	
	var target: Node2D
	if target_node:
		target = target_node
	if bouncing_back and player:
		target = player
	
	if target:
		var direction: Vector2 = Vector2.from_angle(lerp_angle(global_position.direction_to(target.global_position).angle(), linear_velocity.angle() + PI, 0.3))
		var distance := global_position.distance_to(target.global_position)
		var force := Vector2(0.0, 0.0)
		if direction:
			force = direction * SPEED * distance * (1 + speed_increase_time * 100)
		
		if distance > 1000:
			player.orb_count += 1
			queue_free()

		apply_force(force)

		if (
			global_position.x < target.global_position.x + 50
			and global_position.x > target.global_position.x - 50
			and global_position.y < target.global_position.y + 50 and global_position.y
			> target.global_position.y - 50
		):
			#if bounces == 0:
			bouncing_back = true
			set_axis_velocity(Vector2())
			if player:
				apply_impulse(global_position.direction_to(player.global_position) * 400)
			#else:
			#	target_position = enemies[0].position
			#	bounces -= 1

		if bouncing_back and player:
			if (
				global_position.x < player.position.x + 50
				and global_position.x > player.position.x - 50
				and global_position.y < player.position.y + 50
				and global_position.y > player.position.y - 50
			):
				player.orb_count += 1
				queue_free()


func _on_body_entered(body: EnemyNode) -> void:
	if body.is_in_group("enemy"):
		if body.take_damage:
			body.take_damage(1)
			enemies = get_tree().get_nodes_in_group("enemy")
		if bounces == 0:
			bouncing_back = true
			linear_velocity /= 10
			if player:
				apply_impulse(global_position.direction_to(player.global_position) * 200)
		else:
			var closest_distance:float
			var closest_enemy:Node2D
			for enemy:Node2D in enemies:
				if enemy != body:
					if !closest_distance:
						closest_distance = global_position.distance_to(enemy.global_position)
						closest_enemy = enemy
					elif global_position.distance_to(enemy.global_position) < closest_distance:
						closest_distance = global_position.distance_to(enemy.global_position)
						closest_enemy = enemy
			if closest_enemy:
				linear_velocity /= 2
				target_node = closest_enemy
				apply_impulse(global_position.direction_to(target_node.global_position) * 300)
			bounces -= 1
