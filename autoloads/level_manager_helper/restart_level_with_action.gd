extends Node


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		@warning_ignore("unsafe_method_access")
		LevelManagerHelper.load_current_level_transition()
