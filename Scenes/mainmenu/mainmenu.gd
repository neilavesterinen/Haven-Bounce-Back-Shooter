extends CanvasLayer

@onready var VBOX: VBoxContainer = $Control/VBoxContainer
@onready var title: FloatingLabel = $Label

func tween_buttons_out() -> void:
	var tween := create_tween()
	tween.tween_property(VBOX, "position:x", VBOX.position.x - 500, 0.5).set_trans(Tween.TRANS_SINE)

func _on_play_pressed() -> void:
	print("Starting Game")
	tween_buttons_out()
	LevelManagerHelper.load_level_num_transition(1)

func _on_settings_pressed() -> void:
	tween_buttons_out()
	
	# The label has its own looping float tween on position:y. Stop it so both
	# tweens don't fight over the same property.
	title.stop_floating()
	var start_y := title.base_y
	
	var tween_up := create_tween().set_trans(Tween.TRANS_SINE)
	tween_up.tween_property(title, "position:y", start_y - 144, 0.5)
	
	await tween_up.finished
	await get_tree().create_timer(0.5).timeout
	
	var tween_down := create_tween().set_trans(Tween.TRANS_SINE)
	tween_down.tween_property(title, "position:y", start_y, 0.5)
	
	await tween_down.finished
	title.start_floating()
