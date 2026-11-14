extends Label

@export var float_distance: float = 10.0
@export var duration: float = 2.0

func _ready() -> void:
	await get_tree().process_frame
	
	var start_y: float = position.y
	var tween: Tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "position:y", start_y - float_distance, duration)
	tween.tween_property(self, "position:y", start_y, duration)
