extends Button

@export var upgrade: StringName
@export var price_label: Label

var _upgrade_state: UpgradeManager.UpgradeState


func _ready() -> void:
	pressed.connect(_on_pressed)

	_upgrade_state = UpgradeManager.get_upgrade_state(upgrade)

	_update_price()


func _on_pressed() -> void:
	if GameState.points < _upgrade_state.price():
		return

	_upgrade_state.level_up()
	GameState.points -= _upgrade_state.price()

	_update_price()


func _update_price() -> void:
	price_label.text = str(_upgrade_state.price())
