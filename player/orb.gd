extends RigidBody2D
class_name Orb

const BASE_SPEED := 700.0
const MAX_SPEED := 1800.0
const SPEED_GROWTH := 1.6  # speed multiplier gained per second while homing
const HOMING_RATE := 3.0  # how quickly steering blends from the bounce to the player
const CATCH_RADIUS := 50.0

var player: Player

var enemies: Array

var target_position: Vector2

var bounces := 2

var bouncing_back := false

var bounce_elapsed := 0.0

var steer := 0.0  # 0 = follow bounce_dir, 1 = head straight for the player

var bounce_dir: Vector2

var bounce_target: Vector2

@onready var trail: Line2D = $Line2D


func _ready() -> void:
	rotate(randi_range(0, 350))
	enemies = get_tree().get_nodes_in_group("enemy")


func blend_directions(dir_a: Vector2, dir_b: Vector2, weight: float) -> Vector2:
	var a := dir_a.normalized()
	var b := dir_b.normalized()
	if a == Vector2.ZERO:
		return b
	if b == Vector2.ZERO:
		return a
	return a.slerp(b, clampf(weight, 0.0, 1.0))


func _physics_process(delta: float) -> void:
	trail.add_point(global_position)
	if trail.points.size() > 50:
		trail.points.slice(50)
	rotate(5 * delta)

	var move_dir: Vector2
	var speed: float

	if bouncing_back and player:
		bounce_elapsed += delta
		# Exponential ease-in: starts on the bounce direction, asymptotically homes on the player.
		steer = 1.0 - exp(-HOMING_RATE * bounce_elapsed)

		var away := global_position.direction_to(bounce_target)
		var home := global_position.direction_to(player.global_position)
		move_dir = blend_directions(away, home, steer)

		speed = minf(BASE_SPEED * pow(SPEED_GROWTH, bounce_elapsed), MAX_SPEED)
	else:
		move_dir = global_position.direction_to(target_position)
		speed = BASE_SPEED

	if move_dir != Vector2.ZERO:
		linear_velocity = move_dir * speed

	if not bouncing_back and global_position.distance_squared_to(target_position) <= CATCH_RADIUS * CATCH_RADIUS:
		bounce_dir = global_position.direction_to(player.global_position)
		bounce_target = global_position + bounce_dir * 500.0
		bounce_back()

	if bouncing_back and player and global_position.distance_squared_to(player.global_position) <= CATCH_RADIUS * CATCH_RADIUS:
		player.orb_count += 1
		queue_free()


func bounce_back() -> void:
	if not player: return
	if bouncing_back: return
	bouncing_back = true
	bounce_elapsed = 0.0
	if bounce_dir == Vector2.ZERO:
		bounce_dir = global_position.direction_to(player.global_position)
		bounce_target = global_position + bounce_dir * 500.0
	linear_velocity = bounce_dir * BASE_SPEED


func _on_body_entered(body: Node2D) -> void:
	if not body is Enemy:
		return
	var enemy := body as Enemy
	enemy.health -= 1
	if bouncing_back:
		return

	var normal := (global_position - body.global_position).normalized()
	var incoming := linear_velocity.normalized()
	if incoming == Vector2.ZERO:
		incoming = global_position.direction_to(target_position)
	bounce_dir = incoming.bounce(normal)
	bounce_target = global_position + bounce_dir * 500.0
	bounce_back()
