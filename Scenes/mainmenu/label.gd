class_name FloatingLabel
extends Label

@export var float_distance: float = 10.0
@export var duration: float = 2.0

# The y position the label floats around. Other scripts should animate towards
# this value so the float restart doesn't make the label jump back.
var base_y: float

var float_tween: Tween

func _ready() -> void:
	base_y = position.y
	await get_tree().process_frame
	start_floating()

func start_floating() -> void:
	stop_floating()

	float_tween = create_tween().set_loops()
	float_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	float_tween.tween_property(self, "position:y", base_y - float_distance, duration)
	float_tween.tween_property(self, "position:y", base_y, duration)

func stop_floating() -> void:
	if float_tween and float_tween.is_valid():
		float_tween.kill()
	float_tween = null
