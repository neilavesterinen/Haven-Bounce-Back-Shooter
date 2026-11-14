@tool
extends StaticBody2D

@export var shape_color: Color = Color.CORNFLOWER_BLUE:
	set(value):
		shape_color = value
		queue_redraw()

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
		
	var shape = collision_shape.shape
	var offset = collision_shape.position
	
	if shape is RectangleShape2D:
		var rect = Rect2(offset - shape.size / 2.0, shape.size)
		draw_rect(rect, shape_color)
