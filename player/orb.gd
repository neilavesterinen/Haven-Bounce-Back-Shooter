class_name Orb
extends RigidBody2D

const BASE_SPEED := 700.0
const MAX_SPEED := 1800.0
const SPEED_GROWTH := 1.6 # speed multiplier gained per second while homing
const TURN_RATE := 6.0 # minimum radians per second the orb turns toward the player
const CATCH_RADIUS := 50.0

@export var explode: PackedScene
@export var max_bounces: Attribute
@export var damage: Attribute

var player: Player

var enemies: Array

var target_position: Vector2

var bounce_count := 0 # enemy deflections used so far

var bouncing_back := false

var bounce_elapsed := 0.0

var heading: Vector2

var bounce_dir: Vector2

var exploding: bool = false

var current_speed := BASE_SPEED

@onready var Sprite: Sprite2D = $Sprite2D
@onready var trail: Line2D = $Sprite2D/Line2D
@onready var area: Area2D = $Area2D


func _ready() -> void:
	rotate(randi_range(0, 350))
	enemies = get_tree().get_nodes_in_group("enemy")


func _physics_process(delta: float) -> void:
	if exploding:
		return
	if trail:
		if trail.points.size() > 50:
			trail.remove_point(0)
		trail.add_point(global_position)

	var speed: float

	if bouncing_back and player:
		bounce_elapsed += delta
		speed = minf(BASE_SPEED * pow(SPEED_GROWTH, bounce_elapsed), MAX_SPEED)

		# Keep the turn radius below the distance to the player. A fixed turn rate
		# gives a 300 px radius at MAX_SPEED, which is larger than CATCH_RADIUS,
		# so the orb could orbit the player forever. Half the distance guarantees
		# the orb out-turns the bearing to the player and spirals inward.
		var to_player := player.global_position - global_position
		var distance := maxf(to_player.length(), 1.0)
		var turn_radius := maxf(distance * 0.5, 16.0)
		var max_turn := maxf(speed / turn_radius, TURN_RATE) * delta
		var home := to_player / distance
		var turn := clampf(heading.angle_to(home), -max_turn, max_turn)
		heading = heading.rotated(turn)
	else:
		heading = global_position.direction_to(target_position)
		speed = BASE_SPEED

	if heading != Vector2.ZERO:
		linear_velocity = heading * speed

	current_speed = speed

	if (
		not bouncing_back
		and global_position.distance_squared_to(target_position) <= CATCH_RADIUS ** 2
	):
		bounce_dir = global_position.direction_to(player.global_position)
		bounce_back()

	if (
		bouncing_back and player
		and global_position.distance_squared_to(player.global_position) <= CATCH_RADIUS ** 2
	):
		exploder()

	if bounce_count >= max_bounces.get_value_int():
		modulate = Color("3c3c3c79")
		trail.gradient.set_color(1, Color("ae5fff5e"))
		if area:
			area.queue_free()


func exploder() -> void:
	exploding = true
	var expl: AnimatedSprite2D = explode.instantiate()
	expl.position = position
	player.orb_count += 1
	if Sprite:
		Sprite.queue_free()
	if area:
		area.queue_free()
	#add_child(expl)
	# await expl.animation_finished
	queue_free()


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if exploding:
		return

	for i in state.get_contact_count():
		var normal := state.get_contact_local_normal(i).normalized()
		if normal == Vector2.ZERO:
			continue
		# Contacts can persist for a frame after the deflection. Only bounce
		# while the orb is still moving into the surface.
		if heading.dot(normal) >= 0.0:
			continue

		var incoming := linear_velocity.normalized()
		if incoming == Vector2.ZERO:
			incoming = heading

		bounce_dir = incoming.bounce(normal)
		if bounce_dir == Vector2.ZERO:
			bounce_dir = normal

		bounce_elapsed *= 0.75
		# Wall/object deflections do not use up the enemy bounce count.
		_bounce()
		state.linear_velocity = heading * current_speed
		break


func bounce_back() -> void:
	if not player:
		return
	_bounce()
	linear_velocity = heading * BASE_SPEED


func _bounce() -> void:
	if not bouncing_back:
		bouncing_back = true
		bounce_elapsed = 0.0
	heading = bounce_dir
	if heading == Vector2.ZERO and player:
		heading = global_position.direction_to(player.global_position)


func _on_body_entered(body: Node2D) -> void:
	var enemy := body as Enemy
	if not enemy:
		return
	enemy.take_damage(damage.get_value_int())

	if max_bounces.get_value_int() > 0 and bounce_count >= max_bounces.get_value_int():
		return

	var normal := (global_position - body.global_position).normalized()
	var incoming := heading
	if incoming == Vector2.ZERO:
		incoming = linear_velocity.normalized()
	if incoming == Vector2.ZERO:
		incoming = global_position.direction_to(target_position)

	bounce_dir = incoming.bounce(normal)
	bounce_elapsed *= 0.75
	bounce_count += 1
	bounce_back()
