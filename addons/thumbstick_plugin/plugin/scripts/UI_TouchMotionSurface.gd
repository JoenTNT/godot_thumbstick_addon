@tool
class_name UI_TouchMotionSurface extends Control

# TODO: Coming Soon!
signal on_touch_pressed(finger_index: int, pressed_position: Vector2);
signal on_touch_dragged(finger_index: int, drag_dir: Vector2);
signal on_touch_tap(figner_index: int, tap_position: Vector2);
signal on_touch_released(figner_index: int, latest_position: Vector2);

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch_input(event as InputEventScreenTouch);
	if event is InputEventScreenDrag:
		_on_touch_drag(event as InputEventScreenDrag);

func _on_touch_input(e: InputEventScreenTouch) -> void:
	pass;

func _on_touch_drag(e: InputEventScreenDrag) -> void:
	pass;
