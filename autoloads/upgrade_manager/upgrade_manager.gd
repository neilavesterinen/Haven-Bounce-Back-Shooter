extends Node

@export var upgrades: Array[Upgrade]

var _upgrade_state_by_name: Dictionary[StringName, UpgradeState]


func _ready() -> void:
	for upgrade in upgrades:
		_upgrade_state_by_name[upgrade.name] = UpgradeState.construct(0, upgrade)


func get_upgrade_state(upgrade_name: StringName) -> UpgradeState:
	assert(_upgrade_state_by_name.has(upgrade_name), "Invalid upgrade name: " + upgrade_name)

	return _upgrade_state_by_name[upgrade_name]


class UpgradeState:
	var level: int = 0

	var upgrade: Upgrade


	static func construct(p_level: int, p_upgrade: Upgrade) -> UpgradeState:
		var upgrade_state := UpgradeState.new()

		upgrade_state.level = p_level
		upgrade_state.upgrade = p_upgrade

		return upgrade_state


	func price() -> int:
		return upgrade.price(level)


	func level_up() -> void:
		level += 1
