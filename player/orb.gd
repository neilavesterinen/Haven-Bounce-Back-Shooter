extends RigidBody2D
class_name Orb

const BASE_SPEED := 700.0
const MAX_SPEED := 1800.0
const SPEED_GROWTH := 1.6  # speed multiplier gained per second while homing
const TURN_RATE := 6.0  # radians per second the orb turns toward the player
const CATCH_RADIUS := 50.0

var player: Player

var enemies: Array

var target_position: Vector2

var bounces := 2

var bouncing_back := false

var bounce_elapsed := 0.0

var heading: Vector2

var bounce_dir: Vector2

@onready var trail: Line2D = $Line2D
@onready var Sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	rotate(randi_range(0, 350))
	enemies = get_tree().get_nodes_in_group("enemy")


func _physics_process(delta: float) -> void:
	if trail.points.size() > 50:
		trail.remove_point(trail.points.size()-1)
	trail.add_point(global_position)
	Sprite.rotate(5 * delta)

	var speed: float

	if bouncing_back and player:
		bounce_elapsed += delta
		# Rotate the heading toward the player at a limited rate to get a missile arc.
		var home := global_position.direction_to(player.global_position)
		var turn := clampf(heading.angle_to(home), -TURN_RATE * delta, TURN_RATE * delta)
		heading = heading.rotated(turn)

		speed = minf(BASE_SPEED * pow(SPEED_GROWTH, bounce_elapsed), MAX_SPEED)
	else:
		heading = global_position.direction_to(target_position)
		speed = BASE_SPEED

	if heading != Vector2.ZERO:
		linear_velocity = heading * speed

	if not bouncing_back and global_position.distance_squared_to(target_position) <= CATCH_RADIUS * CATCH_RADIUS:
		bounce_dir = global_position.direction_to(player.global_position)
		bounce_back()

	if bouncing_back and player and global_position.distance_squared_to(player.global_position) <= CATCH_RADIUS * CATCH_RADIUS:
		player.orb_count += 1
		queue_free()


func bounce_back() -> void:
	if not player: return
	if bouncing_back: return
	bouncing_back = true
	bounce_elapsed = 0.0
	heading = bounce_dir
	if heading == Vector2.ZERO:
		heading = global_position.direction_to(player.global_position)
	linear_velocity = heading * BASE_SPEED


func _on_body_entered(body: Node2D) -> void:
	bounce_elapsed = bounce_elapsed - bounce_elapsed/4
	if not body is Enemy:
		return
	var enemy := body as Enemy
	enemy.health -= 1

	var normal := (global_position - body.global_position).normalized()
	var incoming := linear_velocity.normalized()
	if incoming == Vector2.ZERO:
		incoming = global_position.direction_to(target_position)
	bounce_dir = incoming.bounce(normal)
	bounce_back()
