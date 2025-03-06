class_name SAMPLE_PhysicalTouchColliderEffect
extends Node2D

const TOUCH_COLLIDER_KEY: String = "collider";
const EXPECTED_POSITION_KEY: String = "expected_pos";

@export var _touch_collider_preset: PackedScene = null;

# Runtime variable data.
var _cache_touch_points: Dictionary = {};
var _temp_touch_info: Dictionary;
var _temp_touch_collider: CollisionShape2D;
var _expected_position: Vector2;

func _physics_process(delta: float) -> void:
	for k in _cache_touch_points.keys():
		_temp_touch_info = _cache_touch_points[k];
		_temp_touch_collider = _temp_touch_info[TOUCH_COLLIDER_KEY];
		if _temp_touch_collider.disabled: continue;
		_expected_position = _temp_touch_info[EXPECTED_POSITION_KEY];
		_temp_touch_collider.set_deferred(&"global_position", _expected_position);

func on_pressed(arg: MultiTouchOnPressed) -> void:
	_temp_touch_info = _cache_touch_points.get_or_add(arg.finger_index, {});
	if not _temp_touch_info.has(TOUCH_COLLIDER_KEY):
		_temp_touch_collider = _touch_collider_preset.instantiate();
		_temp_touch_info[TOUCH_COLLIDER_KEY] = _temp_touch_collider;
		call_deferred(&"add_child", _temp_touch_collider);
	_temp_touch_collider = _temp_touch_info[TOUCH_COLLIDER_KEY];
	_temp_touch_info[EXPECTED_POSITION_KEY] = arg.pressed_position;
	_temp_touch_collider.set_deferred(&"disabled", false);

func on_dragged(args: MultiTouchOnDragged) -> void:
	_temp_touch_info = _cache_touch_points[args.finger_index];
	_temp_touch_collider = _temp_touch_info[TOUCH_COLLIDER_KEY];
	_temp_touch_info[EXPECTED_POSITION_KEY] = args.drag_pos;

func on_released(args: MultiTouchOnReleased) -> void:
	_temp_touch_info = _cache_touch_points[args.figner_index];
	_temp_touch_collider = _temp_touch_info[TOUCH_COLLIDER_KEY];
	_temp_touch_collider.disabled = true;
