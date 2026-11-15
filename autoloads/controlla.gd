extends Node

signal input_device_changed(is_controller: bool)

var is_using_controller: bool = false
var last_device_id: int = 0

const JOYPAD_DEADZONE: float = 0.2

func _input(event: InputEvent) -> void:
	var new_state := is_using_controller

	if event is InputEventKey or event is InputEventMouseButton:
		new_state = false
	elif event is InputEventMouseMotion:
		var mouse_motion := event as InputEventMouseMotion
		if mouse_motion.relative.length() > 1.0:
			new_state = false
	elif event is InputEventJoypadButton:
		new_state = true
		last_device_id = event.device
	elif event is InputEventJoypadMotion:
		var joypad_motion := event as InputEventJoypadMotion
		if abs(joypad_motion.axis_value) > JOYPAD_DEADZONE:
			new_state = true
			last_device_id = joypad_motion.device

	if new_state != is_using_controller:
		is_using_controller = new_state
		input_device_changed.emit(is_using_controller)
