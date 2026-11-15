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
	var offset := collision_shape.position

	var shape: RectangleShape2D = collision_shape.shape as RectangleShape2D
	if shape:
		var rect := Rect2(offset - shape.size / 2.0, shape.size)
		draw_rect(rect, shape_color)
