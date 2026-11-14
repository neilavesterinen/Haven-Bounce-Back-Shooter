extends Node

@export var level_load_transition: StringName = "fade"

var _level_load_function_to_call: Callable
var _is_loading_level: bool = false


## Calling this will load a level with a specific level numbers as defined in the
## level manager scene.
func load_level_num_transition(level_num: int) -> void:
	if not _start_loading_level():
		return

	_level_load_function_to_call = LevelManager.load_level_num.bind(level_num)

	_do_transition()


## Calling this directly will set the loaded level num to -1, if you want to load
## a numbered level, please call [method load_level_num_transition] instead.
func load_level_path_transition(level_path: String) -> void:
	if not _start_loading_level():
		return

	_level_load_function_to_call = LevelManager.load_level_path.bind(level_path)

	_do_transition()


## A simple method to call [code]load_level_num_relatively_transition(1)[/code].
func load_next_level_transition() -> void:
	load_level_num_relatively_transition(1)


## Loads a level num relative to the current level num.
## E.g. [param relative_level_num] of 1 will load the next level.
## Though in that case use [method load_next_level] to be clearer.
##
## This will fail if in a non numbered level.
func load_level_num_relatively_transition(relative_level_num: int) -> void:
	if not _start_loading_level():
		return

	_level_load_function_to_call = LevelManager.load_level_num_relatively.bind(relative_level_num)

	_do_transition()


## This is just a restart level function, named like this to be consistent with the other functions.
func load_current_level_transition() -> void:
	if not _start_loading_level():
		return

	_level_load_function_to_call = LevelManager.load_current_level

	_do_transition()


# Returns false if couldn't start loading level
func _start_loading_level() -> bool:
	if _is_loading_level:
		return false
	_is_loading_level = true

	return true


func _do_transition() -> void:
	TransitionManager.transition_fully_visible.connect(
		_on_load_level_transition_fully_visible,
		CONNECT_ONE_SHOT,
	)
	TransitionManager.transition_come(level_load_transition)


func _on_load_level_transition_fully_visible() -> void:
	_level_load_function_to_call.call()
	_is_loading_level = false
