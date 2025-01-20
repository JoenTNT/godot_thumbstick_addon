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

func on_pressed(index: int, touch_amount: int, pressed_position: Vector2) -> void:
	_temp_touch_info = _cache_touch_points.get_or_add(index, {});
	if not _temp_touch_info.has(TOUCH_COLLIDER_KEY):
		_temp_touch_collider = _touch_collider_preset.instantiate();
		_temp_touch_info[TOUCH_COLLIDER_KEY] = _temp_touch_collider;
		call_deferred(&"add_child", _temp_touch_collider);
	_temp_touch_collider = _temp_touch_info[TOUCH_COLLIDER_KEY];
	_temp_touch_info[EXPECTED_POSITION_KEY] = pressed_position;
	_temp_touch_collider.set_deferred(&"disabled", false);

func on_dragged(index: int, drag_pos: Vector2, drag_dir: Vector2, drag_magnitude: float) -> void:
	_temp_touch_info = _cache_touch_points[index];
	_temp_touch_collider = _temp_touch_info[TOUCH_COLLIDER_KEY];
	_temp_touch_info[EXPECTED_POSITION_KEY] = drag_pos;

func on_released(index: int, touch_amount: int, latest_position: Vector2) -> void:
	_temp_touch_info = _cache_touch_points[index];
	_temp_touch_collider = _temp_touch_info[TOUCH_COLLIDER_KEY];
	_temp_touch_collider.disabled = true;
