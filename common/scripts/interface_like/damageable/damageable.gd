class_name Damageable
extends Area2D
## This is meant to be added to a collider, so other scripts can check if it has this and then call the methods.

## Sent when this takes damage succesfully
signal damaged(damage: int, damage_team: DamageTeam, damage_type: DamageType)

enum DamageTeam {
	PLAYER,
	ENEMY,
}
enum DamageType {
	GENERIC,
}


func damage(
	amount: int,
	damage_team: DamageTeam,
	damage_type: DamageType = DamageType.GENERIC,
) -> void:
	damaged.emit(amount, damage_team, damage_type)
