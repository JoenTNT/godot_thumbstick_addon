@tool
class_name UI_JoystickController extends Control

# NOTE: Y Axis is inversed by default, up means minus.
## Event called when pointer touch begin only inside the area.
signal on_pressed(pressPosition: Vector2);

## Event called when tap on the joystick area.
signal on_tap(tapPosition: Vector2);

## Event called when dragging trigger, 
## input value will always has radius magnitude from 0 to 1.
signal on_trigger(input_v: Vector2, elapsed: float);

## Event called when pointer touch just has been released.
signal on_released(releasePosition: Vector2, elapsed: float);

# Constants alias.
const MSTC = THUMMBSTICK_CONSTANTS.TJC_MODE_STATIC;
const MDMC = THUMMBSTICK_CONSTANTS.TJC_MODE_DYNAMIC;
const MFLW = THUMMBSTICK_CONSTANTS.TJC_MODE_FOLLOW;
const VALW = THUMMBSTICK_CONSTANTS.TJC_VISIBILITY_ALWAYS;
const VTCS = THUMMBSTICK_CONSTANTS.TJC_VISIBILITY_TOUCHSCREEN;
const IDSB = THUMMBSTICK_CONSTANTS.TJC_INPUT_DISABLED;
const ITAP = THUMMBSTICK_CONSTANTS.TJC_INPUT_TAPONLY;
const IHZT = THUMMBSTICK_CONSTANTS.TJC_INPUT_HORIZONTALONLY;
const IVCT = THUMMBSTICK_CONSTANTS.TJC_INPUT_VERTICALONLY;
const INOR = THUMMBSTICK_CONSTANTS.TJC_INPUT_NORMAL;
const MOUSE_FROM_TOUCH_SETTING = "input_devices/pointing/emulate_mouse_from_touch";
const TOUCH_FROM_MOUSE_SETTING = "input_devices/pointing/emulate_touch_from_mouse";

@export_group("Properties")
## Joystick control mode used.
@export_enum(MSTC, MDMC, MFLW) var _mode: String = MDMC;
@export_enum(VALW, VTCS) var _joystick_visibility: String = VALW;
# TODO: Make input mode works.
@export_enum(IDSB, ITAP, IHZT, IVCT, INOR) var _input_mode: String = INOR;
@export var _out_follow_radius_tolerance: float = 10.0;
## Maximum pixel radius on screen the inner joystick can be dragged.
@export var _max_drag_radius: float = 56.0:
	set(p_max_drag_radius):
		if p_max_drag_radius < 0.0: p_max_drag_radius = 0.0;
		_max_drag_radius = p_max_drag_radius;
## Move touch by distance in screen space to start trigger input.
@export var _trigger_threshold: float = 16.0;
## Radius in percentage of deadzone, 
## if input [color=FFFF00]percent value[/color] less than the [b]Deadzone[/b] value, 
## it outputs as zero.
@export_range(0.0, 1.0) var _dead_zone: float = 0.2;
## The seconds between 
@export_range(0.0, 12.0) var _tap_cancel_threshold: float = 0.2;
## Elapsed seconds begin when joystick first time triggered instead of pressed.
@export var _elapse_start_on_trigger: bool = true;
## Resulting 0 and 1 instead of using range between.
@export var _normalize_input: bool = false;
## If [code]true[/code], then input value result will be negated.
@export var _inverse_input_v: bool = false;
## Joystick disabled state.
# TODO: Will be removed due to already input mode.
@export var _disabled: bool = false;

@export_group("Coloring Style")
## Joystick base color, will be multiplied by tint colors in runtime.
@export var _base_color: Color = Color.WHITE;
@export var _inner_normal_tint: Color = Color.WHITE;
@export var _bg_normal_tint = Color.WHITE;
@export var _inner_pressed_tint: Color = Color.GRAY;
@export var _bg_pressed_tint = Color.WHITE;
@export var _inner_disabled_int: Color = Color(0.6, 0.6, 0.6, 0.4);
@export var _bg_disabled_tint = Color(0.6, 0.6, 0.6, 0.4);

@export_group("Optional Dependency")
## Once it is filled, all methods inside the node will be called.
@export var control_target_node: Node = null;
# These methods is automatically called if target was filled.
@export var _on_trigger_method_name: String = "on_trigger";
@export var _on_tap_method_name: String = "on_tap";
@export var _on_pressed_method_name: String = "on_pressed";
@export var _on_released_method_name: String = "on_released";

@export_group("DEBUGGER")
@export var _debug_mode: bool = false;
@export var _editor_warnings: bool = false;

# Runtime variable data.
@onready var _root: Window = get_tree().root;
@onready var _outer_joystick: TextureRect = $"Outer BG";
@onready var _inner_joystick: TextureRect = $"Outer BG/Inner CTRL";
@onready var _outer_origin_position: Vector2 = $"Outer BG".get_screen_position();
@onready var _inner_origin_position: Vector2 = $"Outer BG/Inner CTRL".get_screen_position();
var _touch_position_cache: Vector2 = Vector2.ZERO;
var _start_press_position: Vector2 = Vector2.ZERO;
var _drag_position: Vector2 = Vector2.ZERO;
var _elapsed_time_started: float = 0.0;
var _trigger_direction: Vector2 = Vector2.ZERO;
var _trigger_magnitude: float = 0.0;
var _touch_index: int = -1;
var _is_pressed: bool = false;
var _is_triggered: bool = false;
var _running_in_editor: bool = false;
var _unix_time: float = 0.0;
var _expected_outer_position: Vector2 = Vector2.ZERO;
var _expected_inner_position: Vector2 = Vector2.ZERO;
var _expected_outer_color: Color = Color.BLACK;
var _expected_inner_color: Color = Color.BLACK;

func _ready() -> void:
	_running_in_editor = Engine.is_editor_hint();
	if _running_in_editor: if !_editor_warnings: return;
	var mft: bool = ProjectSettings.get_setting(MOUSE_FROM_TOUCH_SETTING);
	var tfm: bool = ProjectSettings.get_setting(TOUCH_FROM_MOUSE_SETTING);
	if mft:
		print_rich("[color=FDD303]Warning: \"Project Settings -> Pointing" +
			"-> emulate_mouse_from_touch must\" be uncheck.");
	if not tfm:
		print_rich("[color=FDD303]Warning: \"Project Settings -> Pointing" +
			"-> emulate_touch_from_mouse\" must be checked.");
	if _running_in_editor: return;
	_expected_inner_position = _inner_origin_position;
	_expected_outer_position = _outer_origin_position;
	set_disabled(_disabled);
	# Subscribe events.
	_root.size_changed.connect(_on_viewport_size_changed);

func _exit_tree() -> void:
	_running_in_editor = Engine.is_editor_hint();
	if _running_in_editor: return;
	# Unsubscribe events.
	_root.size_changed.disconnect(_on_viewport_size_changed);

func _input(event: InputEvent) -> void:
	_running_in_editor = Engine.is_editor_hint();
	if _running_in_editor: return;
	if _disabled: return;
	_unix_time = Time.get_unix_time_from_system();
	if event is InputEventScreenTouch:
		_input_screen_touch(event as InputEventScreenTouch, _unix_time);
	elif event is InputEventScreenDrag:
		_input_screen_drag(event as InputEventScreenDrag, _unix_time);
	_on_display_update();

func _input_screen_touch(e: InputEventScreenTouch, t: float) -> void:
	_touch_position_cache = e.position;
	if e.pressed && _is_point_inside_area(_touch_position_cache):
		if _is_pressed: return;
		_touch_index = e.index;
		_on_pressed(_touch_position_cache, t);
	if not e.pressed:
		if !_is_pressed || _touch_index != e.index: return;
		_on_released(_touch_position_cache, t - _elapsed_time_started);

func _input_screen_drag(e: InputEventScreenDrag, t: float) -> void:
	if !_is_pressed: return;
	if e.index != _touch_index: return;
	_drag_position = e.position;
	if _is_triggered:
		_on_trigger(_drag_position, t - _elapsed_time_started);
		return;
	if !_is_trigger(_start_press_position, _drag_position, _trigger_threshold):
		_on_before_trigger(_drag_position, t - _elapsed_time_started);
		return;
	if _elapse_start_on_trigger: _elapsed_time_started = t;
	_is_triggered = true;

func _on_pressed(start_point: Vector2, start_t: float) -> void:
	_start_press_position = start_point;
	if !_elapse_start_on_trigger: _elapsed_time_started = start_t;
	# Calculate input, setting status, and predict display update.
	var outer_half: Vector2 = _outer_joystick.size / 2.0;
	match _mode:
		MSTC:
			if !_is_point_inside_joystick_outer(_start_press_position): return;
			_is_pressed = true;
			_start_press_position = _outer_joystick.global_position + outer_half;
		MDMC, MFLW:
			_is_pressed = true;
			_expected_outer_position = _start_press_position - outer_half;
			_expected_inner_position = _start_press_position - _inner_joystick.size / 2.0;
			_expected_outer_color = _base_color * _bg_pressed_tint;
			_expected_inner_color = _base_color * _inner_pressed_tint;
	# Call Event
	if control_target_node != null:
		if control_target_node.has_method(_on_pressed_method_name):
			control_target_node.call(_on_pressed_method_name, _start_press_position);
	on_pressed.emit(_start_press_position);

func _on_before_trigger(pre_point: Vector2, _pre_t: float) -> void:
	var inner_half: Vector2 = _inner_joystick.size / 2.0;
	_trigger_direction = pre_point - _start_press_position;
	_expected_inner_position = _start_press_position + _trigger_direction - inner_half;

func _on_trigger(point: Vector2, elapsed: float):
	_trigger_direction = point - _start_press_position;
	_trigger_magnitude = _trigger_direction.length();
	# Calculate input, setting status, and predict display update.
	var inner_half: Vector2 = _inner_joystick.size / 2.0;
	var normal_dir: Vector2 = _trigger_direction.normalized();
	var final_result: Vector2;
	var is_deadzone: bool; var input_v: float; 
	match _mode:
		MDMC, MSTC:
			if _trigger_magnitude > _max_drag_radius:
				_trigger_direction = normal_dir * _max_drag_radius;
				_trigger_magnitude = _trigger_direction.length();
			input_v = _trigger_magnitude / _max_drag_radius;
			is_deadzone = input_v <= _dead_zone;
			_expected_inner_position = _start_press_position + _trigger_direction - inner_half;
			if is_deadzone:
				_trigger_direction = Vector2(0.0, 0.0);
				_trigger_magnitude = 0.0;
				input_v = 0.0;
			if _normalize_input: input_v = 1.0;
			final_result = (-1 if _inverse_input_v else 1) * normal_dir * input_v;
		MFLW:
			var move_outer_rad: float = 0.0;
			var out_tol: float = _max_drag_radius + _out_follow_radius_tolerance;
			if _trigger_magnitude > out_tol:
				move_outer_rad = _trigger_magnitude - out_tol;
			if _trigger_magnitude > _max_drag_radius:
				_trigger_direction = normal_dir * _max_drag_radius;
				_trigger_magnitude = _trigger_direction.length();
			var outer_half: Vector2 = _outer_joystick.size / 2.0;
			_start_press_position += normal_dir * move_outer_rad;
			_expected_outer_position = _start_press_position - outer_half;
			_expected_inner_position = _start_press_position + _trigger_direction - inner_half;
			input_v = _trigger_magnitude / _max_drag_radius;
			is_deadzone = input_v <= _dead_zone;
			if is_deadzone:
				_trigger_direction = Vector2(0.0, 0.0);
				_trigger_magnitude = 0.0;
				input_v = 0.0;
			if _normalize_input: input_v = 1.0;
			final_result = (-1 if _inverse_input_v else 1) * normal_dir * input_v;
	# Call event.
	if control_target_node != null:
		if control_target_node.has_method(_on_trigger_method_name):
			control_target_node.call(_on_trigger_method_name, final_result, elapsed);
	on_trigger.emit(final_result, elapsed);
	if _debug_mode:
		print("TDir = ({xDir}, {yDir}); M = {mag}; DZ = ({is_dead}); Out = {o}".format({
			"xDir": "%.f" % _trigger_direction.x,
			"yDir": "%.f" % _trigger_direction.y,
			"mag": "%.2f" % _trigger_magnitude,
			"is_dead": is_deadzone,
			"o": final_result,
		}))

func _on_released(last_point: Vector2, last_elapsed: float) -> void:
	_is_pressed = false;
	_is_triggered = false;
	_touch_index = -1;
	_expected_outer_position = _outer_origin_position;
	_expected_inner_position = _inner_origin_position;
	_expected_outer_color = _base_color * _bg_normal_tint;
	_expected_inner_color = _base_color * _inner_normal_tint;
	# Call events.
	if last_elapsed < _tap_cancel_threshold:
		if control_target_node != null:
			if control_target_node.has_method(_on_tap_method_name):
				control_target_node.call(_on_tap_method_name, last_point);
		on_tap.emit(last_point);
	if control_target_node != null:
		if control_target_node.has_method(_on_released_method_name):
			control_target_node.call(_on_released_method_name, last_point, last_elapsed);
	on_released.emit(last_point, last_elapsed);

func _is_point_inside_area(point: Vector2) -> bool:
	var cs: Vector2 = get_global_transform_with_canvas().get_scale();
	var gs: Vector2 = global_position;
	var sz: Vector2 = size;
	return (point.x >= gs.x && point.x <= gs.x + (sz.x * cs.x)) && (
		point.y >= gs.y && point.y <= gs.y + (sz.y * cs.y));

func _is_point_inside_joystick_outer(point: Vector2) -> bool:
	var cos: Vector2 = _outer_joystick.get_global_transform_with_canvas().get_scale();
	var gs: Vector2 = _outer_joystick.global_position;
	var sz: Vector2 = _outer_joystick.size;
	return (point.x >= gs.x && point.x <= gs.x + (sz.x * cos.x)) && (
		point.y >= gs.y && point.y <= gs.y + (sz.y * cos.y));

func _is_trigger(a: Vector2, b: Vector2, t: float) -> bool:
	return a.distance_to(b) >= t;

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_unix_time = Time.get_unix_time_from_system();
		if !visible && _is_pressed:
			_on_released(_touch_position_cache, _unix_time);

func _on_viewport_size_changed() -> void:
	_outer_joystick.global_position = _outer_origin_position;
	_inner_joystick.global_position = _inner_origin_position;

func _on_display_update() -> void:
	_outer_joystick.set_global_position(_expected_outer_position);
	_inner_joystick.set_global_position(_expected_inner_position);
	_outer_joystick.self_modulate = _expected_outer_color;
	_inner_joystick.self_modulate = _expected_inner_color;

func set_joystick_mode(mode: String) -> void:
	_mode = mode;

func get_joystick_mode() -> String:
	return _mode;

func set_base_color(c: Color) -> void:
	_base_color = c;

func get_base_color() -> Color:
	return _base_color;

func set_disabled(disable: bool) -> void:
	_disabled = disable;
	if _disabled:
		_expected_outer_color = _base_color * _bg_disabled_tint;
		_expected_inner_color = _base_color * _inner_disabled_int;
	else:
		_expected_outer_color = _base_color * _bg_normal_tint;
		_expected_inner_color = _base_color * _inner_normal_tint;
	if _disabled && _is_pressed:
		_unix_time = Time.get_unix_time_from_system();
		_on_released(_touch_position_cache, _unix_time);
	_on_display_update();

func get_disabled() -> bool:
	return _disabled;
	
func set_enabled(enable: bool) -> void:
	_disabled = !enable;
	if _disabled:
		_expected_outer_color = _base_color * _bg_disabled_tint;
		_expected_inner_color = _base_color * _inner_disabled_int;
	else:
		_expected_outer_color = _base_color * _bg_normal_tint;
		_expected_inner_color = _base_color * _inner_normal_tint;
	if _disabled && _is_pressed:
		_unix_time = Time.get_unix_time_from_system();
		_on_released(_touch_position_cache, _unix_time);
	_on_display_update();

func get_enabled() -> bool:
	return !_disabled;

func set_control_target_node(t: Node) -> void:
	control_target_node = t;

func get_control_target_node() -> Node:
	return control_target_node;

# TODO: Export with conditions.
#func _get_property_list() -> Array[Dictionary]:
	#if !Engine.is_editor_hint():
		#var ret;
		#return ret;
