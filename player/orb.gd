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


func _physics_process(delta: float) -> void:
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

	if not bouncing_back and _is_at(target_position):
		bounce_back()

	if bouncing_back and player and _is_at(player.global_position):
		player.orb_count += 1
		queue_free()


func _is_at(point: Vector2) -> bool:
	return (
		global_position.x < point.x + 50
		and global_position.x > point.x - 50
		and global_position.y < point.y + 50
		and global_position.y > point.y - 50
	)


func bounce_back() -> void:
	if not player:
		return
	bouncing_back = true
	set_axis_velocity(Vector2())
	apply_impulse(global_position.direction_to(player.global_position) * 400)


func _on_body_entered(body: Node2D) -> void:
	if not body is Enemy:
		return
	var enemy := body as Enemy
	enemy.health -= 1
	if not bouncing_back:
		bounce_back()
