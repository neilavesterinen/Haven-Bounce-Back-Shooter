extends RigidBody2D
class_name Orb

var player: Player

var target_position: Vector2

var SPEED := 10.0

var bouncing_back := false

var speed_increase_time := 0.0

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
		bouncing_back = true
		set_axis_velocity(Vector2())
		apply_impulse(global_position.direction_to(player.global_position) * 400)

	if bouncing_back and player:
		if (
			global_position.x < player.position.x + 50
			and global_position.x > player.position.x - 50
			and global_position.y < player.position.y + 50
			and global_position.y > player.position.y - 50
		):
			player.orb_count += 1
			queue_free()
