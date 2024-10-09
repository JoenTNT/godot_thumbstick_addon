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
const IHZT = THUMMBSTICK_CONSTANTS.TJC_INPUT_HORIZONTALONLY;
const IVCT = THUMMBSTICK_CONSTANTS.TJC_INPUT_VERTICALONLY;
const INOR = THUMMBSTICK_CONSTANTS.TJC_INPUT_NORMAL;
const ASSETS_PATH = "res://addons/thumbstick_plugin/plugin/assets/";
const MOUSE_FROM_TOUCH_SETTING = "input_devices/pointing/emulate_mouse_from_touch";
const TOUCH_FROM_MOUSE_SETTING = "input_devices/pointing/emulate_touch_from_mouse";
const DEFAULT_FOLLOW_RADIUS_TOLERANCE: float = 10.0;
const DEFAULT_EXTEND_STATIC_AREA_TRIGGER: Vector2 = Vector2(24.0, 24.0);
const DEFAULT_MAX_PULL_RADIUS: float = 64.0;
const DEFAULT_START_TRIGGER_THRESHOLD: float = 16.0;
const DEFAULT_DEADZONE_PERCENT: float = 0.2;
const DEFAULT_CANCEL_TAP_TRIGGER_THRESHOLD: float = 0.2;
const DEFAULT_STYLE: Dictionary = {
	"base_color": Color.WHITE,
	"normal_background_tint": Color.WHITE,
	"normal_handle_tint": Color.WHITE,
	"pressed_background_tint": Color.WHITE,
	"pressed_handle_tint": Color.GRAY,
	"disabled_background_tint": Color(0.6, 0.6, 0.6, 0.4),
	"disabled_handle_tint": Color(0.6, 0.6, 0.6, 0.4),
	"transparent_background_tint": Color(1.0, 1.0, 1.0, 0.35),
	"transparent_handle_tint": Color(1.0, 1.0, 1.0, 0.5),
};
const DEFAULT_TRIGGER_FUNCTIONS: Dictionary = {
	"on_trigger_method": "on_trigger",
	"on_pressed_method": "on_pressed",
	"on_released_method": "on_released",
	"on_tap_method": "on_tap",
};

# Properties
## Joystick control mode used.
var _mode: String = MDMC:
	set(p_joystick_mode):
		_mode = p_joystick_mode;
		notify_property_list_changed();
var _visibility_mode: String = VALW:
	set(p_visibility):
		_visibility_mode = p_visibility;
		notify_property_list_changed();
# TODO: Make input mode works.
var _input_mode: String = INOR;
# TODO: Make extra static size triggerable.
var extend_static_area_trigger: Vector2 = DEFAULT_EXTEND_STATIC_AREA_TRIGGER:
	set(p_sst):
		if p_sst.x < 0.0: p_sst.x = 0.0;
		if p_sst.y < 0.0: p_sst.y = 0.0; 
		extend_static_area_trigger = p_sst;
# TODO: Fix Bug where the extra radius does not work.
## Extra radius in follow mode,
## prevents joystick display move until exceeds this tolerance.
var follow_radius_tolerance: float = DEFAULT_FOLLOW_RADIUS_TOLERANCE:
	set(p_ofradt):
		if p_ofradt < 0.0: p_ofradt = 0.0;
		follow_radius_tolerance = p_ofradt;
## Maximum pixel radius on screen the inner joystick can be dragged.
var max_drag_radius: float = DEFAULT_MAX_PULL_RADIUS:
	set(p_max_drag_radius):
		if p_max_drag_radius < 0.0: p_max_drag_radius = 0.0;
		max_drag_radius = p_max_drag_radius;
## Move touch by distance in screen space to start trigger input.
var start_trigger_threshold: float = DEFAULT_START_TRIGGER_THRESHOLD:
	set(p_threshold):
		if p_threshold < 0.0: p_threshold = 0.0;
		start_trigger_threshold = p_threshold;
## Radius in percentage of deadzone, 
## if [color=FFFF00]percentage value[/color] less than the [b]Deadzone[/b], 
## it outputs zero.
var deadzone_radius_percentage: float = DEFAULT_DEADZONE_PERCENT;
## The seconds allowed to cancel a tap input.
var cancel_tap_trigger_threshold: float = DEFAULT_CANCEL_TAP_TRIGGER_THRESHOLD:
	set(p_cancel_thrsld):
		if p_cancel_thrsld < 0.0: p_cancel_thrsld = 0.0;
		cancel_tap_trigger_threshold = p_cancel_thrsld;
## Elapsed seconds begin when the joystick is first triggered instead of pressed.
var start_elapsed_on_trigger: bool = true;
## Resulting output only equal 0 or 1 instead of using range between.
var normalize_output: bool = false;
## If [code]true[/code], then output value will be negated.
var inverse_output: bool = false;
## Enable or disable tap trigger functionality.
var enable_tap_trigger: bool = true:
	set(p_enabled):
		enable_tap_trigger = p_enabled;
		notify_property_list_changed();
## Joystick disabled state.
var joystick_disabled: bool = false;

# Styles
## Joystick base color, will be multiplied by tint colors in runtime.
var _base_color: Color = DEFAULT_STYLE["base_color"];
## Multiply color tint for background with base color at normal state.
var _normal_bg_tint: Color = DEFAULT_STYLE["normal_background_tint"];
## Multiply color tint for inner handle with base color at normal state.
var _normal_handle_tint: Color = DEFAULT_STYLE["normal_handle_tint"];
## Multiply color tint for background with base color at pressed state.
var _pressed_bg_tint: Color = DEFAULT_STYLE["pressed_background_tint"];
## Multiply color tint for inner handle with base color at pressed state.
var _pressed_handle_tint: Color = DEFAULT_STYLE["pressed_handle_tint"];
## Multiply color tint for background with base color at disabled state.
var _disabled_bg_tint: Color = DEFAULT_STYLE["disabled_background_tint"];
## Multiply color tint for inner handle with base color at disabled state.
var _disabled_handle_tint: Color = DEFAULT_STYLE["disabled_handle_tint"];
## Invisible colored background tint for inactive touch screen visibility mode
## only when the joystick is not being touched.
var _transparent_bg_tint: Color = DEFAULT_STYLE["transparent_background_tint"];
## Invisible colored inner handle tint for inactive touch screen visibility mode
## only when the joystick is not being touched.
var _transparent_handle_tint: Color = DEFAULT_STYLE["transparent_handle_tint"];

# Controlling target.
## Once it is filled, all methods inside the node will be called.
var control_target_node: Node = null;
# These methods is automatically called if target was filled.
## Calling method on trigger ([color=FE861A][b]Control Target Node[/b][/color] must be filled)
var _on_trigger_method_name: String = DEFAULT_TRIGGER_FUNCTIONS["on_trigger_method"];
## Calling method on pressed ([color=FE861A][b]Control Target Node[/b][/color] must be filled)
var _on_pressed_method_name: String = DEFAULT_TRIGGER_FUNCTIONS["on_pressed_method"];
## Calling method on released ([color=FE861A][b]Control Target Node[/b][/color] must be filled)
var _on_released_method_name: String = DEFAULT_TRIGGER_FUNCTIONS["on_released_method"];
## Calling method on tap ([color=FE861A][b]Control Target Node[/b][/color] must be filled)
var _on_tap_method_name: String = DEFAULT_TRIGGER_FUNCTIONS["on_tap_method"];

# Debugger
## Open debug mode, only works in editor.
var _debug_mode: bool = false:
	set(p_debug):
		_debug_mode = p_debug;
		notify_property_list_changed();
## Visualization control hint in scene for development purpose.
var _visualize_gizmos: bool = true;
## Recolor text hint with color, useful to prevent camouflage against background.
var _text_hint_color: Color = Color.BLACK;
## Open subgroup of statistic in Inspector when the game is running.
var _show_testing_info: bool = false:
	set(p_debug):
		_show_testing_info = p_debug;
		notify_property_list_changed();
## Notice developer for editor only warnings.
var _editor_warnings: bool = true;

# Runtime variable data.
@onready var _root: Window = get_tree().root;
@onready var _outer_joystick: TextureRect = $"Outer BG";
@onready var _inner_joystick: TextureRect = $"Outer BG/Inner CTRL";
@onready var _outer_origin_position: Vector2 = $"Outer BG".get_screen_position();
@onready var _inner_origin_position: Vector2 = $"Outer BG/Inner CTRL".get_screen_position();

var _touch_index: int = -1;
var _touch_pressed_position: Vector2 = Vector2.ZERO;
var _touch_position_cache: Vector2 = Vector2.ZERO;
var _trigger_direction: Vector2 = Vector2.ZERO;
var _trigger_magnitude: float = 0.0;
var _outer_half_size: Vector2 = Vector2.ZERO;
var _inner_half_size: Vector2 = Vector2.ZERO;

var _expected_outer_position: Vector2 = Vector2.ZERO;
var _expected_inner_position: Vector2 = Vector2.ZERO;
var _expected_outer_color: Color = Color.BLACK;
var _expected_inner_color: Color = Color.BLACK;

var _elapsed_time_started: float = 0.0;
var _control_elapsed_time: float = 0.0;
var _unix_time_now: float = 0.0;

var _inside_deadzone: bool = false;
var _is_pressed: bool = false;
var _is_triggered: bool = false;

# Runtime debug variable data.
var _running_in_editor: bool = false;
var _gizmos_color: Color = Color.BLACK;

#region Property Drawer
func _get_property_list() -> Array[Dictionary]:
	var r: Array[Dictionary] = [{
		"name": "Main Properties",
		"type": TYPE_STRING_NAME,
		"usage": PROPERTY_USAGE_GROUP,
	}, {
		"name": &"_mode",
		"type": TYPE_STRING_NAME,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "%s,%s,%s" % [MSTC, MDMC, MFLW],
		"usage": PROPERTY_USAGE_DEFAULT,
	}];
	r.append_array([{
		"name": &"_visibility_mode",
		"type": TYPE_STRING_NAME,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "%s,%s" % [VALW, VTCS],
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"_input_mode",
		"type": TYPE_STRING_NAME,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "%s,%s,%s" % [IHZT, IVCT, INOR],
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": "Controller Settings",
		"type": TYPE_STRING_NAME,
		"usage": PROPERTY_USAGE_SUBGROUP,
	}]);
	if _mode == MSTC:
		r.append({
			"name": &"extend_static_area_trigger",
			"type": TYPE_VECTOR2,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
		});
	if _mode == MFLW:
		r.append({
			"name": &"follow_radius_tolerance",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
		});
	r.append_array([{
		"name": &"max_drag_radius",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"start_trigger_threshold",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"deadzone_radius_percentage",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "%f,%f" % [0.0, 1.0],
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"start_elapsed_on_trigger",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"normalize_output",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"inverse_output",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"enable_tap_trigger",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
	}]);
	if enable_tap_trigger:
		r.append({
			"name": &"cancel_tap_trigger_threshold",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_DEFAULT,
		})
	r.append_array([{
		"name": "Editable Status",
		"type": TYPE_STRING_NAME,
		"usage": PROPERTY_USAGE_SUBGROUP,
	}, {
		"name": &"joystick_disabled",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
	}]);
	r.append_array([{
		"name": "Style",
		"type": TYPE_STRING_NAME,
		"usage": PROPERTY_USAGE_GROUP,
	}, {
		"name": &"_base_color",
		"type": TYPE_COLOR,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"_normal_bg_tint",
		"type": TYPE_COLOR,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"_normal_handle_tint",
		"type": TYPE_COLOR,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"_pressed_bg_tint",
		"type": TYPE_COLOR,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"_pressed_handle_tint",
		"type": TYPE_COLOR,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"_disabled_bg_tint",
		"type": TYPE_COLOR,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"_disabled_handle_tint",
		"type": TYPE_COLOR,
		"usage": PROPERTY_USAGE_DEFAULT,
	}]);
	if _visibility_mode == VTCS:
		r.append_array([{
			"name": &"_transparent_bg_tint",
			"type": TYPE_COLOR,
			"usage": PROPERTY_USAGE_DEFAULT,
		}, {
			"name": &"_transparent_handle_tint",
			"type": TYPE_COLOR,
			"usage": PROPERTY_USAGE_DEFAULT,
		}]);
	r.append_array([{
		"name": "Single Control Target",
		"type": TYPE_STRING_NAME,
		"usage": PROPERTY_USAGE_GROUP,
	}, {
		"name": &"control_target_node",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_NODE_TYPE,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"_on_trigger_method_name",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"_on_pressed_method_name",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"_on_released_method_name",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
	}, {
		"name": &"_on_tap_method_name",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
	}]);
	r.append_array([{
		"name": "Debugger",
		"type": TYPE_STRING_NAME,
		"usage": PROPERTY_USAGE_GROUP,
	}, {
		"name": &"_debug_mode",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
	}]);
	if _debug_mode:
		r.append_array([{
			"name": "Debug Mode Activators",
			"type": TYPE_STRING_NAME,
			"usage": PROPERTY_USAGE_SUBGROUP,
		}, {
			"name": &"_visualize_gizmos",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
		}, {
			"name": &"_text_hint_color",
			"type": TYPE_COLOR,
			"usage": PROPERTY_USAGE_DEFAULT,
		}, {
			"name": &"_show_testing_info",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
		}]);
	r.append_array([{
		"name": "Debugger",
		"type": TYPE_STRING_NAME,
		"usage": PROPERTY_USAGE_GROUP,
	}, {
		"name": &"_editor_warnings",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
	}]);
	if _show_testing_info:
		# TODO: Draw cached informations in inspector.
		r.append_array([{
			"name": "Simulation Statistic",
			"type": TYPE_STRING_NAME,
			"usage": PROPERTY_USAGE_GROUP,
		}, {
			"name": &"_touch_index",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}, {
			"name": &"_touch_pressed_position",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}, {
			"name": &"_touch_position_cache",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}, {
			"name": &"_trigger_direction",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}, {
			"name": &"_trigger_magnitude",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}, {
			"name": "Render Info",
			"type": TYPE_STRING_NAME,
			"usage": PROPERTY_USAGE_SUBGROUP,
		}, {
			"name": &"_expected_outer_position",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}, {
			"name": &"_expected_inner_position",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}, {
			"name": &"_expected_outer_color",
			"type": TYPE_COLOR,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}, {
			"name": &"_expected_inner_color",
			"type": TYPE_COLOR,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}, {
			"name": "Time Info",
			"type": TYPE_STRING_NAME,
			"usage": PROPERTY_USAGE_SUBGROUP,
		}, {
			"name": &"_elapsed_time_started",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}, {
			"name": &"_unix_time_now",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}, {
			"name": "Status Info",
			"type": TYPE_STRING_NAME,
			"usage": PROPERTY_USAGE_SUBGROUP,
		}, {
			"name": &"_is_pressed",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}, {
			"name": &"_is_trigger(",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}, {
			"name": &"_inside_deadzone",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		}]);
	return r;

func _property_can_revert(property: StringName) -> bool:
	match property:
		&"_mode": return _mode != MDMC;
		&"_visibility_mode": return _visibility_mode != VALW;
		&"_input_mode": return _input_mode != INOR;
		&"max_drag_radius": return max_drag_radius != DEFAULT_MAX_PULL_RADIUS;
		&"start_trigger_threshold":
			return start_trigger_threshold != DEFAULT_START_TRIGGER_THRESHOLD;
		&"deadzone_radius_percentage":
			return deadzone_radius_percentage != DEFAULT_DEADZONE_PERCENT;
		&"cancel_tap_trigger_threshold":
			return cancel_tap_trigger_threshold != DEFAULT_CANCEL_TAP_TRIGGER_THRESHOLD;
		&"start_elapsed_on_trigger": return start_elapsed_on_trigger;
		&"normalize_output": return normalize_output;
		&"inverse_output": return inverse_output;
		&"enable_tap_trigger": return !enable_tap_trigger;
		&"joystick_disabled": return joystick_disabled;
		&"follow_radius_tolerance":
			return follow_radius_tolerance != DEFAULT_FOLLOW_RADIUS_TOLERANCE;
		&"extend_static_area_trigger":
			return extend_static_area_trigger != DEFAULT_EXTEND_STATIC_AREA_TRIGGER;
		&"_base_color":
			return _base_color != DEFAULT_STYLE["base_color"];
		&"_normal_bg_tint":
			return _normal_bg_tint != DEFAULT_STYLE["normal_background_tint"];
		&"_normal_handle_tint":
			return _normal_handle_tint != DEFAULT_STYLE["normal_handle_tint"];
		&"_pressed_bg_tint":
			return _pressed_bg_tint != DEFAULT_STYLE["pressed_background_tint"];
		&"_pressed_handle_tint":
			return _pressed_handle_tint != DEFAULT_STYLE["pressed_handle_tint"];
		&"_disabled_bg_tint":
			return _disabled_bg_tint != DEFAULT_STYLE["disabled_background_tint"];
		&"_disabled_handle_tint":
			return _disabled_handle_tint != DEFAULT_STYLE["disabled_handle_tint"];
		&"_transparent_bg_tint":
			return _transparent_bg_tint != DEFAULT_STYLE["transparent_background_tint"];
		&"_transparent_handle_tint":
			return _transparent_handle_tint != DEFAULT_STYLE["transparent_handle_tint"];
		&"control_target_node": return control_target_node != null;
		&"_on_trigger_method_name":
			return _on_trigger_method_name != DEFAULT_TRIGGER_FUNCTIONS["on_trigger_method"];
		&"_on_pressed_method_name":
			return _on_pressed_method_name != DEFAULT_TRIGGER_FUNCTIONS["on_pressed_method"];
		&"_on_released_method_name":
			return _on_released_method_name != DEFAULT_TRIGGER_FUNCTIONS["on_released_method"];
		&"_on_tap_method_name":
			return _on_tap_method_name != DEFAULT_TRIGGER_FUNCTIONS["on_tap_method"];
		&"_debug_mode": return _debug_mode;
		&"_editor_warnings": return !_editor_warnings;
		&"_visualize_gizmos": return !_visualize_gizmos;
		&"_text_hint_color": return _text_hint_color != Color.BLACK;
		&"_show_testing_info": return _show_testing_info;
		_: return false;

func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"_mode": return MDMC;
		&"_visibility_mode": return VALW;
		&"_input_mode": return INOR;
		&"max_drag_radius": return DEFAULT_MAX_PULL_RADIUS;
		&"start_trigger_threshold": return DEFAULT_START_TRIGGER_THRESHOLD;
		&"deadzone_radius_percentage": return DEFAULT_DEADZONE_PERCENT;
		&"cancel_tap_trigger_threshold": return DEFAULT_CANCEL_TAP_TRIGGER_THRESHOLD;
		&"start_elapsed_on_trigger": return false;
		&"normalize_output": return false;
		&"inverse_output": return false;
		&"enable_tap_trigger": return true;
		&"joystick_disabled": return false;
		&"follow_radius_tolerance": return DEFAULT_FOLLOW_RADIUS_TOLERANCE;
		&"extend_static_area_trigger": return DEFAULT_EXTEND_STATIC_AREA_TRIGGER;
		&"_base_color": return DEFAULT_STYLE["base_color"];
		&"_normal_bg_tint": return DEFAULT_STYLE["normal_background_tint"];
		&"_normal_handle_tint": return DEFAULT_STYLE["normal_handle_tint"];
		&"_pressed_bg_tint": return DEFAULT_STYLE["pressed_background_tint"];
		&"_pressed_handle_tint": return DEFAULT_STYLE["pressed_handle_tint"];
		&"_disabled_bg_tint": return DEFAULT_STYLE["disabled_background_tint"];
		&"_disabled_handle_tint": return DEFAULT_STYLE["disabled_handle_tint"];
		&"_transparent_bg_tint": return DEFAULT_STYLE["transparent_background_tint"];
		&"_transparent_handle_tint": return DEFAULT_STYLE["transparent_handle_tint"];
		&"control_target_node": return null;
		&"_on_trigger_method_name": return DEFAULT_TRIGGER_FUNCTIONS["on_trigger_method"];
		&"_on_pressed_method_name": return DEFAULT_TRIGGER_FUNCTIONS["on_pressed_method"];
		&"_on_released_method_name": return DEFAULT_TRIGGER_FUNCTIONS["on_released_method"];
		&"_on_tap_method_name": return DEFAULT_TRIGGER_FUNCTIONS["on_tap_method"];
		&"_debug_mode": return false;
		&"_editor_warnings": return true;
		&"_visualize_gizmos": return true;
		&"_text_hint_color": return Color.BLACK;
		&"_show_testing_info": return false;
		_: return null;

# TODO: Editor runtime update buttons in inspector.
func _add_inspector_buttons() -> Array[Dictionary]:
	var btns: Array[Dictionary] = [{
		"name": "Debug Mode %s" % ("On" if _debug_mode else "Off"),
		"pressed": _on_inspector_debug_mode_button_pressed,
	}];
	return btns;

func _on_inspector_debug_mode_button_pressed() -> void:
	_debug_mode = !_debug_mode;
	notify_property_list_changed();
#endregion

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
	_inside_deadzone = true;
	_expected_inner_position = _inner_origin_position;
	_expected_outer_position = _outer_origin_position;
	set_disabled(joystick_disabled);
	# Subscribe events.
	_root.size_changed.connect(_on_viewport_size_changed);

func _exit_tree() -> void:
	_running_in_editor = Engine.is_editor_hint();
	if _running_in_editor: return;
	# Unsubscribe events.
	_root.size_changed.disconnect(_on_viewport_size_changed);

func _process(delta: float) -> void:
	_running_in_editor = Engine.is_editor_hint();
	if !_running_in_editor: return;
	# Handle Color Preview.
	if joystick_disabled:
		_outer_joystick.self_modulate = _base_color * _disabled_bg_tint;
		_inner_joystick.self_modulate = _base_color * _disabled_handle_tint;
	elif _visibility_mode == VTCS:
		_outer_joystick.self_modulate = _base_color * _transparent_bg_tint;
		_inner_joystick.self_modulate = _base_color * _transparent_handle_tint;
	else:
		_outer_joystick.self_modulate = _base_color * _normal_bg_tint;
		_inner_joystick.self_modulate = _base_color * _normal_handle_tint;
	queue_redraw();

func _draw() -> void:
	if !_debug_mode || !_visualize_gizmos: return;
	if _outer_joystick == null: _outer_joystick = $"Outer BG";
	_outer_half_size = _outer_joystick.size / 2.0;
	if _inner_joystick == null: _inner_joystick = $"Outer BG/Inner CTRL";
	_inner_half_size = _inner_joystick.size / 2.0;
	var touch_area_pos: Vector2 = Vector2(0.0, 0.0);
	var mid_joystick_pos: Vector2 = _outer_joystick.position + _outer_half_size;
	var radius_hint: float = _inner_half_size.x + max_drag_radius;
	# Coloring follow extend area.
	if _mode == MFLW:
		_gizmos_color = Color.VIOLET;
		_gizmos_color.a = 0.5;
		draw_circle(mid_joystick_pos, radius_hint + follow_radius_tolerance, _gizmos_color);
	# Coloring Max Pull Radius.
	if _inside_deadzone:
		_gizmos_color = Color.YELLOW;
		_gizmos_color.a = 0.3;
		draw_circle(mid_joystick_pos, radius_hint, _gizmos_color);
		var dead_zone_radius = _inner_half_size.x + max_drag_radius * deadzone_radius_percentage;
		_gizmos_color = Color.RED;
		_gizmos_color.a = 0.7;
		draw_circle(mid_joystick_pos, dead_zone_radius, _gizmos_color);
	else:
		_gizmos_color = Color.GREEN;
		_gizmos_color.a = 0.3;
		draw_circle(mid_joystick_pos, radius_hint, _gizmos_color);
		var dead_zone_radius = _inner_half_size.x + max_drag_radius * deadzone_radius_percentage;
		_gizmos_color = Color.YELLOW;
		_gizmos_color.a = 0.7;
		draw_circle(mid_joystick_pos, dead_zone_radius, _gizmos_color);
	# Coloring touchable area.
	_gizmos_color = Color.AQUAMARINE;
	_gizmos_color.a = 0.15;
	if _mode == MDMC || _mode == MFLW:
		draw_rect(Rect2(touch_area_pos, size), _gizmos_color);
	var static_extra_pos: Vector2 = Vector2.ZERO;
	if _mode == MSTC:
		var static_trigger_half: Vector2 = extend_static_area_trigger / 2.0;
		static_extra_pos = _outer_joystick.position - static_trigger_half;
		var static_extra_size: Vector2 = _outer_joystick.size + extend_static_area_trigger;
		draw_rect(Rect2(static_extra_pos, static_extra_size), _gizmos_color);
	_gizmos_color = _text_hint_color;
	_gizmos_color.a = 0.65;
	touch_area_pos += Vector2(4.0, 16.0);
	if _mode == MDMC || _mode == MFLW:
		draw_string(ThemeDB.fallback_font, touch_area_pos,
			"Dynamic Trigger Area" if _mode == MDMC else "Dynamic Follow Trigger Area",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, _gizmos_color);
	elif _mode == MSTC:
		static_extra_pos += Vector2(4.0, -4.0);
		draw_string(ThemeDB.fallback_font, static_extra_pos, "Static Trigger Area",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 12, _gizmos_color);
	# Draw status informations.
	var bottom_outer: Vector2 = _outer_joystick.position + Vector2(0.0, _outer_joystick.size.y);
	bottom_outer += Vector2(-max_drag_radius + 8.0, max_drag_radius - 28.0);
	draw_string(ThemeDB.fallback_font, bottom_outer,
		"Triggered: %s" % ("True" if _is_triggered else "False"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, _gizmos_color);
	if _is_triggered:
		bottom_outer += Vector2(0.0, 14.0);
		draw_string(ThemeDB.fallback_font, bottom_outer,
			"Deadzone: %s" % ("True" if _inside_deadzone else "False"),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, _gizmos_color);
		bottom_outer += Vector2(0.0, 14.0);
		draw_string(ThemeDB.fallback_font, bottom_outer,
			"Direction: {dir}".format({"dir": _trigger_direction.normalized()}),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, _gizmos_color);
		bottom_outer += Vector2(0.0, 14.0);
		draw_string(ThemeDB.fallback_font, bottom_outer,
			"Output: {v}".format({"v": _trigger_direction.length() / max_drag_radius}),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, _gizmos_color);
	else:
		bottom_outer += Vector2(0.0, 14.0);
		draw_string(ThemeDB.fallback_font, bottom_outer,
			"Going to Trigger: {v}/{t}".format({
				"v": _trigger_direction.length(),
				"t": start_trigger_threshold,
			}),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, _gizmos_color);
	# Tell elapsed time.
	bottom_outer += Vector2(0.0, 14.0);
	draw_string(ThemeDB.fallback_font, bottom_outer,
		"Latest Elapsed Time: %.2f" % _control_elapsed_time,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, _gizmos_color);
	if _is_pressed:
		_gizmos_color = Color.BLUE;
		_gizmos_color.a = 0.7;
		draw_circle(_touch_position_cache - global_position, 10.0, _gizmos_color);
	# Coloring Trigger Threshold.
	if _is_pressed && !_is_triggered:
		_gizmos_color = Color.PURPLE;
		_gizmos_color.a = 0.75;
		radius_hint = _inner_half_size.x + start_trigger_threshold;
		draw_circle(mid_joystick_pos, radius_hint, _gizmos_color);

func _input(event: InputEvent) -> void:
	_running_in_editor = Engine.is_editor_hint();
	if _running_in_editor: return;
	if joystick_disabled: return;
	_unix_time_now = Time.get_unix_time_from_system();
	if event is InputEventScreenTouch:
		_input_screen_touch(event as InputEventScreenTouch, _unix_time_now);
	elif event is InputEventScreenDrag:
		_input_screen_drag(event as InputEventScreenDrag, _unix_time_now);
	_on_display_update();
	if !_debug_mode || !_gizmos_color: return;
	queue_redraw();

func _input_screen_touch(e: InputEventScreenTouch, t: float) -> void:
	_touch_position_cache = e.position;
	_inside_deadzone = true;
	if e.pressed && _is_point_inside_area(_touch_position_cache):
		if _is_pressed: return;
		_touch_index = e.index;
		_touch_pressed_position = _touch_position_cache;
		_control_elapsed_time = 0.0;
		_on_pressed(_touch_position_cache, t);
	if not e.pressed:
		if !_is_pressed || _touch_index != e.index: return;
		_control_elapsed_time = t - _elapsed_time_started;
		_on_released(_touch_position_cache, _control_elapsed_time);

func _input_screen_drag(e: InputEventScreenDrag, t: float) -> void:
	if !_is_pressed: return;
	if e.index != _touch_index: return;
	_touch_position_cache = e.position;
	_control_elapsed_time = t - _elapsed_time_started;
	if _is_triggered:
		_on_trigger(_touch_position_cache, _control_elapsed_time);
		return;
	if !_is_trigger(_touch_pressed_position, _touch_position_cache, start_trigger_threshold):
		if start_elapsed_on_trigger: _control_elapsed_time = 0.0;
		_on_before_trigger(_touch_position_cache, _control_elapsed_time);
		return;
	if start_elapsed_on_trigger: _elapsed_time_started = t;
	_is_triggered = true;

func _on_pressed(start_point: Vector2, start_t: float) -> void:
	if !start_elapsed_on_trigger: _elapsed_time_started = start_t;
	# Calculate input, setting status, and predict display update.
	_outer_half_size = _outer_joystick.size / 2.0;
	match _mode:
		MSTC:
			if !_is_point_inside_joystick_outer(start_point): return;
			_is_pressed = true;
			_touch_pressed_position = _outer_joystick.global_position + _outer_half_size;
		MDMC, MFLW:
			_is_pressed = true;
			_expected_outer_position = start_point - _outer_half_size;
			_expected_inner_position = start_point - _inner_joystick.size / 2.0;
			_expected_outer_color = _base_color * _pressed_bg_tint;
			_expected_inner_color = _base_color * _pressed_handle_tint;
	# Call Event
	if control_target_node != null:
		if control_target_node.has_method(_on_pressed_method_name):
			control_target_node.call(_on_pressed_method_name, start_point);
	on_pressed.emit(_touch_pressed_position);

func _on_before_trigger(pre_point: Vector2, _pre_t: float) -> void:
	_inner_half_size = _inner_joystick.size / 2.0;
	_trigger_direction = pre_point - _touch_pressed_position;
	match _input_mode:
		IVCT:
			_trigger_direction.x = 0.0;
			_trigger_magnitude = _trigger_direction.length();
		IHZT:
			_trigger_direction.y = 0.0;
			_trigger_magnitude = _trigger_direction.length();
	_expected_inner_position = _touch_pressed_position + _trigger_direction - _inner_half_size;

func _on_trigger(point: Vector2, elapsed: float):
	_trigger_direction = point - _touch_pressed_position;
	_trigger_magnitude = _trigger_direction.length();
	# Calculate input, setting status, and predict display update.
	_inner_half_size = _inner_joystick.size / 2.0;
	var normal_dir: Vector2 = _trigger_direction.normalized();
	var final_result: Vector2;
	var input_v: float;
	match _input_mode:
		IVCT:
			_trigger_direction.x = 0.0;
			_trigger_magnitude = _trigger_direction.length();
			normal_dir = _trigger_direction.normalized();
		IHZT:
			_trigger_direction.y = 0.0;
			_trigger_magnitude = _trigger_direction.length();
			normal_dir = _trigger_direction.normalized();
	match _mode:
		MDMC, MSTC:
			if _trigger_magnitude > max_drag_radius:
				_trigger_direction = normal_dir * max_drag_radius;
				_trigger_magnitude = _trigger_direction.length();
			input_v = _trigger_magnitude / max_drag_radius;
			_inside_deadzone = input_v <= deadzone_radius_percentage;
			_expected_inner_position = _touch_pressed_position + _trigger_direction - _inner_half_size;
			if _inside_deadzone:
				_trigger_direction = Vector2(0.0, 0.0);
				_trigger_magnitude = 0.0;
				input_v = 0.0;
			if normalize_output: input_v = 1.0;
			final_result = (-1 if inverse_output else 1) * normal_dir * input_v;
		MFLW:
			var move_outer_rad: float = 0.0;
			var out_tol: float = max_drag_radius + follow_radius_tolerance + _inner_half_size.x;
			if _trigger_magnitude > out_tol:
				move_outer_rad = _trigger_magnitude - out_tol;
			if _trigger_magnitude > max_drag_radius:
				_trigger_direction = normal_dir * max_drag_radius;
				_trigger_magnitude = _trigger_direction.length();
			var outer_half: Vector2 = _outer_joystick.size / 2.0;
			_touch_pressed_position += normal_dir * move_outer_rad;
			_expected_outer_position = _touch_pressed_position - outer_half;
			_expected_inner_position = _touch_pressed_position + _trigger_direction - _inner_half_size;
			input_v = _trigger_magnitude / max_drag_radius;
			_inside_deadzone = input_v <= deadzone_radius_percentage;
			if _inside_deadzone:
				_trigger_direction = Vector2(0.0, 0.0);
				_trigger_magnitude = 0.0;
				input_v = 0.0;
			if normalize_output: input_v = 1.0;
			final_result = (-1 if inverse_output else 1) * normal_dir * input_v;
	# Call event.
	if control_target_node != null:
		if control_target_node.has_method(_on_trigger_method_name):
			control_target_node.call(_on_trigger_method_name, final_result, elapsed);
	on_trigger.emit(final_result, elapsed);

func _on_released(last_point: Vector2, last_elapsed: float) -> void:
	_is_pressed = false;
	_is_triggered = false;
	_touch_index = -1;
	_trigger_direction = Vector2.ZERO;
	_trigger_magnitude = 0.0;
	_expected_outer_position = _outer_origin_position;
	_expected_inner_position = _inner_origin_position;
	if _visibility_mode == VTCS:
		_expected_outer_color = _base_color * _transparent_bg_tint;
		_expected_inner_color = _base_color * _transparent_handle_tint;
	else:
		_expected_outer_color = _base_color * _normal_bg_tint;
		_expected_inner_color = _base_color * _normal_handle_tint;
	# Call events.
	if enable_tap_trigger && last_elapsed < cancel_tap_trigger_threshold:
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
	var half_extend: Vector2 = extend_static_area_trigger / 2.0;
	var cos: Vector2 = _outer_joystick.get_global_transform_with_canvas().get_scale();
	var gs: Vector2 = _outer_joystick.global_position - half_extend;
	var sz: Vector2 = _outer_joystick.size + extend_static_area_trigger;
	return (point.x >= gs.x && point.x <= gs.x + (sz.x * cos.x)) && (
		point.y >= gs.y && point.y <= gs.y + (sz.y * cos.y));

func _is_trigger(a: Vector2, b: Vector2, t: float) -> bool:
	return a.distance_to(b) >= t;

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_unix_time_now = Time.get_unix_time_from_system();
		if !visible && _is_pressed:
			_on_released(_touch_position_cache, _unix_time_now);

func _on_viewport_size_changed() -> void:
	_outer_joystick.global_position = _outer_origin_position;
	_inner_joystick.global_position = _inner_origin_position;

func _on_display_update() -> void:
	_outer_joystick.set_global_position(_expected_outer_position);
	_inner_joystick.set_global_position(_expected_inner_position);
	_outer_joystick.self_modulate = _expected_outer_color;
	_inner_joystick.self_modulate = _expected_inner_color;

func set_disabled(disable: bool) -> void:
	joystick_disabled = disable;
	if joystick_disabled:
		_expected_outer_color = _base_color * _disabled_bg_tint;
		_expected_inner_color = _base_color * _disabled_handle_tint;
	elif _visibility_mode == VTCS:
		_expected_outer_color = _base_color * _transparent_bg_tint;
		_expected_inner_color = _base_color * _transparent_handle_tint;
	else:
		_expected_outer_color = _base_color * _normal_bg_tint;
		_expected_inner_color = _base_color * _normal_handle_tint;
	if joystick_disabled && _is_pressed:
		_unix_time_now = Time.get_unix_time_from_system();
		_on_released(_touch_position_cache, _unix_time_now);
	_on_display_update();

func is_disabled() -> bool:
	return joystick_disabled;
	
func set_enabled(enable: bool) -> void:
	joystick_disabled = !enable;
	if joystick_disabled:
		_expected_outer_color = _base_color * _disabled_bg_tint;
		_expected_inner_color = _base_color * _disabled_handle_tint;
	else:
		_expected_outer_color = _base_color * _normal_bg_tint;
		_expected_inner_color = _base_color * _normal_handle_tint;
	if joystick_disabled && _is_pressed:
		_unix_time_now = Time.get_unix_time_from_system();
		_on_released(_touch_position_cache, _unix_time_now);
	_on_display_update();

func is_enabled() -> bool:
	return !joystick_disabled;

## Setting deadzone percentage between 0 and 1.
func set_deadzone(percentage: float) -> void:
	if percentage < 0.0: percentage = 0.0;
	elif percentage > 1.0: percentage = 1.0;
	deadzone_radius_percentage = percentage;

## Returns percentage of max drag radius.
func get_deadzone() -> float:
	return deadzone_radius_percentage;

func set_normalize_output(norm: bool) -> void:
	normalize_output = norm;

func get_normalize_output() -> bool:
	return normalize_output;

func set_inverse_output(inverse: bool) -> void:
	inverse_output = inverse;

func get_inverse_output() -> bool:
	return inverse_output;

func set_enable_tap_trigger(active: bool) -> void:
	enable_tap_trigger = active;

func get_enable_tap_trigger() -> bool:
	return enable_tap_trigger;

func set_joystick_mode(mode: String) -> void:
	_mode = mode;

func get_joystick_mode() -> String:
	return _mode;

func set_base_color(c: Color) -> void:
	_base_color = c;
	if joystick_disabled:
		_expected_outer_color = _base_color * _disabled_bg_tint;
		_expected_inner_color = _base_color * _disabled_handle_tint;
	elif _visibility_mode == VTCS && !_is_pressed:
		_expected_outer_color = _base_color * _transparent_bg_tint;
		_expected_inner_color = _base_color * _transparent_handle_tint;
	elif _is_pressed:
		_expected_outer_color = _base_color * _pressed_bg_tint;
		_expected_inner_color = _base_color * _pressed_handle_tint;
	else: # Normal
		_expected_outer_color = _base_color * _normal_bg_tint;
		_expected_inner_color = _base_color * _normal_handle_tint;
	_on_display_update();

func get_base_color() -> Color:
	return _base_color;

func set_control_target_node(t: Node) -> void:
	control_target_node = t;

func get_control_target_node() -> Node:
	return control_target_node;
