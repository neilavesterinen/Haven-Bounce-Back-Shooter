extends Node

@export var max_health: Attribute

@export var damageable: Damageable
@export var player_parent: Node

var _health: int
var _dead: bool


func die() -> void:
	if _dead:
		return
	_dead = true

	LevelManagerHelper.load_current_level_transition()
	if player_parent:
		player_parent.queue_free()


func _on_damaged(
	damage: int,
	_damage_team: Damageable.DamageTeam,
	_damage_type: Damageable.DamageType,
) -> void:
	_health -= damage

	if _health <= 0:
		die()
