extends CharacterBody2D
class_name Enemy

var MAX_HEALTH := 5
var SPEED := 100

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var health := MAX_HEALTH
@export var player : Player

func _ready() -> void:
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if not player:
		return
	
	nav_agent.target_position = player.global_position
	
	if nav_agent.is_navigation_finished():
		return
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()

	# Calculate velocity toward the next waypoint
	var new_velocity: Vector2 = current_agent_position.direction_to(next_path_position) * SPEED

	# If using NavigationAgent2D avoidance, pass it to velocity; otherwise directly move
	velocity = new_velocity
	move_and_slide()

func take_damage(damage:int) -> void:
	health -= 1
	modulate.a = 1.0 / MAX_HEALTH * health
	if health == 0:
		queue_free()
