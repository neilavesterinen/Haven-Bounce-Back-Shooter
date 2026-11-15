extends Area2D

@export var damage: int = 1

@export var damage_type: Damageable.DamageType = Damageable.DamageType.GENERIC
@export var damage_team: Damageable.DamageTeam = Damageable.DamageTeam.PLAYER


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	var damageable := area as Damageable
	if damageable:
		damageable.damage(damage, damage_team, damage_type)
