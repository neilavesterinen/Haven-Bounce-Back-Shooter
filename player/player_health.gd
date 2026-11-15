extends Node
class_name PlayerHealth

signal health_changed(new_health: int)
signal died

@export var max_health: Attribute

@export var damageable: Damageable
@export var player_parent: Node

var _health: int
var _dead: bool


func _ready() -> void:
	damageable.damaged.connect(_on_damaged)

	_health = max_health.get_value_int()


func die() -> void:
	if _dead:
		return
	_dead = true

	died.emit()

	LevelManagerHelper.load_level_num_relatively_transition(1)
	if player_parent:
		player_parent.queue_free()


func _on_damaged(
	damage: int,
	_damage_team: Damageable.DamageTeam,
	_damage_type: Damageable.DamageType,
) -> void:
	_health -= damage
	health_changed.emit(_health)

	if _health <= 0:
		die()
