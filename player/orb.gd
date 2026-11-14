extends RigidBody2D
class_name Orb

var player: Player

var enemies: Array

var target_position: Vector2

var SPEED := 10.0

var bouncing_back := false

var speed_increase_time := 0.0

var bounces := 2


func _ready() -> void:
	enemies = get_tree().get_nodes_in_group("enemy")


func _process(delta: float) -> void:
	if bouncing_back:
		speed_increase_time += delta

	var target: Vector2
	if bouncing_back and player:
		target = player.global_position
	else:
		target = target_position
	var velocity := Vector2(0.0, 0.0)
	var direction: Vector2 = global_position.direction_to(target)

	var distance := global_position.distance_to(target)
	if direction:
		velocity = direction * SPEED * distance * (1 + speed_increase_time * 100)

	apply_force(velocity)

	if (
		global_position.x < target_position.x + 50
		and global_position.x > target_position.x - 50
		and global_position.y < target_position.y + 50 and global_position.y
		> target_position.y - 50
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


func _on_body_entered(body: Enemy) -> void:
	if body.is_in_group("enemy"):
		body.health -= 1
		#if bounces == 0:
		bouncing_back = true
		set_axis_velocity(Vector2())
		if player:
			apply_impulse(global_position.direction_to(player.global_position) * 400)
		#else:
		#target_position = enemies[0].position
		#bounces -= 1
