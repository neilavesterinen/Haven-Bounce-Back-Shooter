extends Node

@export var upgrades: Array[Upgrade]

var _upgrade_state_by_name: Dictionary[StringName, UpgradeState]


func _ready() -> void:
	for upgrade in upgrades:
		_upgrade_state_by_name[upgrade.name] = UpgradeState.construct(0, upgrade)


func get_upgrade_state(upgrade_name: StringName) -> UpgradeState:
	return _upgrade_state_by_name[upgrade_name]


class UpgradeState:
	var _level: int = 0

	var _upgrade: Upgrade


	static func construct(p_level: int, p_upgrade: Upgrade) -> UpgradeState:
		var upgrade_state := UpgradeState.new()

		upgrade_state._level = p_level
		upgrade_state._upgrade = p_upgrade

		return upgrade_state


	func price() -> int:
		return _upgrade.price(_level)


	func level() -> int:
		return _level
