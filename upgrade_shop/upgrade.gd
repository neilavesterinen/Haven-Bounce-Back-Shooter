class_name Upgrade
extends Resource

@export var name: StringName:
	set(value):
		if value != name:
			# Changes the resource name visible in the inspector from the default to whatever the name is
			resource_name = value
			name = value
	get:
		return name

@export var onetime: bool

@export var starting_price: float
@export var price_increase_multiplier: float = 1


func price(level: int) -> int:
	return ceil(starting_price * (price_increase_multiplier ** level))
