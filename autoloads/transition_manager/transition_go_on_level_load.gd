extends Node


func _ready() -> void:
	LevelManager.level_loaded.connect(_on_level_loaded)

	# The level load signal has already been emitted at this point, so the method must be called like this the first time
	@warning_ignore("unsafe_method_access", "unsafe_property_access")
	TransitionManager.transitions_registered.connect(
		_on_level_loaded.bindv(["", -1]),
		ConnectFlags.CONNECT_ONE_SHOT,
	)


func _on_level_loaded(_level_path: String, _level_num: int) -> void:
	@warning_ignore("unsafe_method_access", "unsafe_property_access")
	TransitionManager.transition_go(LevelManagerHelper.level_load_transition, true)
