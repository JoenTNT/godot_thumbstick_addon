@tool
class_name InspectorEditor_JoystickController extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is UI_JoystickController;

func _parse_begin(object: Object) -> void:
	pass;
