extends Node
## This script allows the loading of levels also supporting level numbers, for an easy load_next_level function.
## The level number is -1 if the level that gets loaded to doesn't have level number, due to it being loaded directly by it's path.

## Gets called right before the current scene gets unloaded.
## Use if you want to get save some information from the scene at that moment.
signal before_level_unloaded(new_level_path: String, new_level_num: int)

signal level_loaded(level_path: String, level_num: int)

@export_file var levels: Array[String]
@export var default_level: int

var _level_scene: PackedScene
# This number is -1, if not in a numbered level
var _loaded_level_num: int = -1
var _loaded_level_path: String

var _level_instance: Node

## The amount of times a levels have been loaded
var _levels_loaded_count: int = 0
##
var _is_just_after_level_load: bool


func _ready() -> void:
	# Set our variables from the starting scene
	_level_instance = get_tree().current_scene
	_loaded_level_path = _level_instance.scene_file_path
	# Find returns -1 if none are found, which we also use as the not-in-a-numbered-level number, so this works just like this
	_loaded_level_num = levels.find(ResourceUID.path_to_uid(_loaded_level_path))
	_level_scene = load(_loaded_level_path)

	# Add the level scene as our child, because when launching the game it starts as the child of root as we didn't instantiate it
	_level_instance.reparent.call_deferred(self)

	_set_and_await_unset_just_after_level_load()


## Calling this will load a level with a specific level numbers as defined in the
## level manager scene.
func load_level_num(level_num: int) -> void:
	if not is_valid_level_number(level_num):
		printerr("No level exists with number: ", level_num)
		return

	_load_level_path_set_num(levels[level_num], level_num)


## Calling this directly will set the loaded level num to -1, if you want to load
## a numbered level, please call [method load_level_num] instead.
func load_level_path(level_path: String) -> void:
	_load_level_path_set_num(level_path, -1)


## This is just a restart level function, named like this to be consistent with the other functions.
func load_current_level() -> void:
	var current_level_num := _loaded_level_num
	load_level_path(_loaded_level_path)
	_loaded_level_num = current_level_num


## A simple method to call [code]load_level_num_relatively(1)[/code].
func load_next_level() -> void:
	load_level_num_relatively(1)


## Loads a level num relative to the current level num.
## E.g. [param relative_level_num] of 1 will load the next level.
## Though in that case use [method load_next_level] to be clearer.
##
## This will fail if in a non numbered level.
func load_level_num_relatively(relative_level_num: int) -> void:
	if _loaded_level_num == -1:
		printerr("Can't load level relatively if in a non-numbered level.")

	if relative_level_num == 0:
		load_current_level()
	else:
		load_level_num(_loaded_level_num + relative_level_num)


## Returns the root node of the **level**, which changes when new levels
## are loaded. So, this is not the actual root node of the game.
func get_level_root_node() -> Node:
	return _level_instance


## Returns the amount of times levels have been loaded since opening the game.
func get_levels_loaded_count() -> int:
	return _levels_loaded_count


## Returns if a level number exists.
func is_valid_level_number(level_num: int) -> bool:
	return level_num >= 0 and level_num < levels.size()


## Returns whether or not a new level was just loaded.
## Useful if you for example don't want to play a land sound if the player becomes grounded immediately when the level is loaded (it starts grounded).
func is_just_after_level_load() -> bool:
	return _is_just_after_level_load


func _load_level_path_set_num(level_path: String, level_num: int) -> void:
	_loaded_level_num = level_num
	before_level_unloaded.emit(level_path, level_num)

	if _level_instance:
		_level_instance.queue_free()
		_level_instance.tree_exited.connect(_load_level_path_after_old_freed.bind(level_path))
	else:
		_load_level_path_after_old_freed(level_path)


func _load_level_path_after_old_freed(level_path: String) -> void:
	# await get_tree().physics_frame
	# await get_tree().physics_frame
	if level_path != _loaded_level_path:
		_level_scene = load(level_path)

		_loaded_level_path = level_path
	_level_instance = _level_scene.instantiate()
	add_child(_level_instance)

	_levels_loaded_count += 1
	_set_and_await_unset_just_after_level_load()
	level_loaded.emit(level_path, _loaded_level_num)

	## This needs to wait for 3 physics frames for detection of ground triggering (or at least for my ground check script sending the signal for landing), idk why not 1 or 2 (2 if this runs before the ground check)


func _set_and_await_unset_just_after_level_load() -> void:
	_is_just_after_level_load = true

	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame

	_is_just_after_level_load = false
