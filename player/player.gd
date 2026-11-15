class_name Player
extends CharacterBody2D

@export var SPEED := 700.0
@export var throw_distance: Attribute

@export var orb_scene: PackedScene

@export var weapon_node: Node2D
@export var orb_sprite: Node2D
@export var orb_spawn: Node2D
@export var player_health: PlayerHealth

var orb_count := 1


var health := 10
func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity = direction * SPEED
	else:
		if !direction.x:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if !direction.y:
			velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()

	weapon_node.look_at(get_global_mouse_position())

	if !orb_count:
		orb_sprite.visible = orb_count
	else:
		orb_sprite.visible = orb_count

	if Input.is_action_just_pressed("click") and orb_count:
		orb_count -= 1

		var orb_node: Orb = orb_scene.instantiate()
		orb_node.player = self
		orb_node.target_position = orb_spawn.global_position + Vector2(
			throw_distance.get_value_float(),
			0,
		).rotated(weapon_node.global_rotation)

		LevelManager.get_level_root_node().add_child(orb_node)
		orb_node.global_position = orb_spawn.global_position
