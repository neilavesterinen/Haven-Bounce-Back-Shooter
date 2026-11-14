extends Node


## Instantiates a scene more conviniently than calling all the required methods manually.
## [param scene] is the scene to instantiate.
## [param pos] is the global position to instantiate the scene in.
## [param rotation] is the rotation to apply to the scene.
## [param global_properties] defines whether the position and rotation should be local or global.
##  !!! [Control] nodes do not have a [member]global_rotation[/member] property, so they will always just set their local one.
## [param parent] is the parent of which the scene will be. If [code]null[/code], the parent will be
## [method LevelManager.get_level_root_node].
func instantiate(
	scene: PackedScene,
	pos: Vector2,
	rotation: float = 0,
	global_properties: bool = true,
	parent: Node = null,
) -> Node:
	return _apply_instantiate_properties(
		scene.instantiate(),
		pos,
		rotation,
		global_properties,
		parent,
	)


## Like the [method instantiate_script_full], but only has [param parent] as an extra parameter, because you probably don't need the others.
## [param parent] explained in [method instantiate].
func instantiate_script(script: GDScript, parent: Node = null) -> Node:
	var script_node := _create_script_node(script)

	if parent:
		parent.add_child(script_node)
	else:
		LevelManager.get_level_root_node().add_child(script_node)

	return script_node


## Has the same parameters as [method instantiate], but instantiates a script instead of a scene.
func instantiate_script_full(
	script: GDScript,
	pos: Vector2,
	rotation: float = 0,
	global_properties: bool = true,
	parent: Node = null,
) -> Node:
	return _apply_instantiate_properties(
		_create_script_node(script),
		pos,
		rotation,
		global_properties,
		parent,
	)


## Delays a function call by [param delay] seconds.
## Used to delay a function call after the freeing of the object which want to do the call, because then you can't just do the [code]await[/code] yourself.
## [param quit_after_level_load] makes the function get canceled if a new level is loaded by [LevelManager] during the delay.
func delay_function(
	load_function: Callable,
	delay: float,
	quit_after_level_load: bool = true,
) -> void:
	var levels_loaded_count_before := LevelManager.get_levels_loaded_count()

	await get_tree().create_timer(delay).timeout

	if (
		quit_after_level_load
		and levels_loaded_count_before != LevelManager.get_levels_loaded_count()
	):
		return

	load_function.call()


## Reparents a node to the [method LevelManager.get_level_root_node] node.
## Useful if you want to move a node away from a node that is going to be freed.
func reparent_to_level_root(node: Node, keep_global_transform: bool = true) -> void:
	node.reparent(LevelManager.get_level_root_node(), keep_global_transform)


## Restarts a tween on a node.
## This is meant to be used by defining a local function using this in your scripts which you can then call conviniently.
## [codeblock]
## var _tween: Tween
##
## func _restart_tween() -> Tween:
##     _tween = GodotUtils.restart_tween(_tween, self)
##     return _tween
##
## func abc() -> void:
##	  _restart_tween() \
##			.tween_property(self, "offset_transform_position", Vector2(0, 0), 0.5) \
##			.set_ease(Tween.EASE_OUT) \
##			.set_trans(Tween.TRANS_BOUNCE)
## [/codeblock]
func restart_tween(tween: Tween, tweener_node: Node) -> Tween:
	if tween:
		tween.kill()

	return tweener_node.create_tween()


## A function that can be used as a null for [Callable]s, because gdscript doesn't have an Option type,
## should never be called so if your code has this as a default argument, check it before calling.
func _null() -> void:
	assert(false, "Null error: This should never be called, just used as a null Callable type")


func _create_script_node(script: GDScript) -> Node:
	var script_node := Node2D.new()
	script_node.set_script(script)

	return script_node


func _apply_instantiate_properties(
	node: Node,
	pos: Vector2,
	rotation: float = 0,
	global_properties: bool = true,
	parent: Node = null,
) -> Node:
	if parent:
		parent.add_child(node)
	else:
		LevelManager.get_level_root_node().add_child(node)

	var node_node_2d := node as Node2D
	if node_node_2d:
		if global_properties:
			node_node_2d.global_position = pos
			node_node_2d.global_rotation = rotation
		else:
			node_node_2d.position = pos
			node_node_2d.rotation = rotation

	var node_control := node as Control
	if node_control:
		if global_properties:
			node_control.global_position = pos
			node_control.rotation = rotation
		else:
			node_control.position = pos
			node_control.rotation = rotation

	return node
