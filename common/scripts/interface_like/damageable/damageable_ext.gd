class_name DamageableExt
extends Damageable

## Sent when this blocks the damage.
signal damage_failed(damage: int, damage_team: DamageTeam, damage_type: DamageType)

@export var team_immunities: Array[DamageTeam]
@export var type_multipliers: Array[DamageTypeMultiplier]

var _type_multiplier_by_type: Dictionary[DamageType, float]


func _ready() -> void:
	for type_multiplier in type_multipliers:
		_type_multiplier_by_type[type_multiplier.type] = type_multiplier.multiplier


func damage(
	amount: int,
	damage_team: DamageTeam,
	damage_type: DamageType = DamageType.GENERIC,
) -> void:
	var effective_damage := amount
	if _type_multiplier_by_type.has(damage_type):
		effective_damage = ceil(effective_damage * _type_multiplier_by_type[damage_type])

	if not team_immunities.has(damage_team) and not effective_damage == 0:
		damaged.emit(amount, damage_type)
	else:
		damage_failed.emit(amount, damage_type)
