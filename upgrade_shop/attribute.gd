extends Resource

@export var connected_upgrade: StringName

@export var base_value: float = 1

@export var per_level_multiplier_addition: float
@export var per_level_addition: float


func get_value_float() -> float:
	var level := UpgradeManager.get_upgrade_state(connected_upgrade).level()

	return base_value * (per_level_multiplier_addition * level) + per_level_addition * level


func get_value_int() -> int:
	return ceil(get_value_float())


func get_value_bool() -> int:
	var level := UpgradeManager.get_upgrade_state(connected_upgrade).level()

	return level > 0
