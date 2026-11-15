extends ProgressBar

@export var player_health: PlayerHealth


func _ready() -> void:
	if player_health == null:
		player_health = _find_player_health()

	if player_health == null:
		push_warning("HealthBar: no PlayerHealth assigned.")
		return

	max_value = player_health.max_health.get_value_int()
	value = max_value

	player_health.health_changed.connect(_on_health_changed)


func _find_player_health() -> PlayerHealth:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return null

	return player.get_node_or_null("PlayerHealth") as PlayerHealth


func _on_health_changed(new_health: int) -> void:
	value = new_health
