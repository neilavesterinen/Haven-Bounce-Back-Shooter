extends CharacterBody2D
class_name Player

@export var SPEED := 700.0

@export var orb_scene: PackedScene

@export var weapon_node: Node2D
@export var orb_sprite: Node2D
@export var orb_spawn: Node2D

var orb_count := 1

var health := 10

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
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
		
		var target_node: Node2D = Node2D.new()
		get_tree().root.add_child(target_node)
		target_node.position = Vector2(300,0).rotated(weapon_node.rotation) + self.position

		var orb_node: Orb = orb_scene.instantiate()
		
		orb_node.player = self
		orb_node.position = orb_spawn.global_position
		orb_node.target_node = target_node
		orb_node.apply_impulse(orb_node.global_position.direction_to(orb_node.target_node.global_position) * 1000)
		
		get_tree().root.add_child(orb_node)
