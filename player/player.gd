extends CharacterBody2D
class_name Player

const SPEED := 300.0

@export var orbsc: PackedScene

@export var weapon_node: Node2D

var orb_count := 1

var health := 10

func _physics_process(delta: float) -> void:
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
		var weapon_sprite : Sprite2D = weapon_node.get_children()[0]
		weapon_sprite.visible = orb_count
	else:
		var weapon_sprite : Sprite2D = weapon_node.get_children()[0]
		weapon_sprite.visible = orb_count

	if Input.is_action_just_pressed("click") and orb_count:
		orb_count -= 1

		var orb_node: Orb = orbsc.instantiate()

		orb_node.player = self
		orb_node.target_position = global_position + Vector2(400, 0).rotated(weapon_node.global_rotation)

		get_tree().root.add_child(orb_node)

		# RigidBody2D only accepts impulses once it is inside the tree.
		orb_node.global_position = global_position
		orb_node.apply_impulse(orb_node.global_position.direction_to(orb_node.target_position) * 1000)
