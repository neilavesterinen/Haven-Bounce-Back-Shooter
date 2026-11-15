extends Node


func load_level_num_relatively_transition_delay(
	relative_level_num: int,
	delay: float,
	quit_after_level_load: bool = true,
) -> void:
	_load_level_num_relatively_transition_delay(relative_level_num, delay, quit_after_level_load)


func load_next_level_transition_delay(delay: float, quit_after_level_load: bool = true) -> void:
	_load_next_level_transition_delay(delay, quit_after_level_load)


## WHY THE LKJISDFJLK DOES THIS FIX THE SIGNAL NOT APPEARING IN THE INSPECTOR???
## Well it works now...
func _load_level_num_relatively_transition_delay(
	relative_level_num: int,
	delay: float,
	quit_after_level_load: bool,
) -> void:
	GodotUtils.delay_function(
		LevelManagerHelper.load_level_num_relatively_transition.bind(relative_level_num),
		delay,
		quit_after_level_load,
	)


func _load_next_level_transition_delay(delay: float, quit_after_level_load: bool) -> void:
	GodotUtils.delay_function(
		LevelManagerHelper.load_next_level_transition,
		delay,
		quit_after_level_load,
	)
