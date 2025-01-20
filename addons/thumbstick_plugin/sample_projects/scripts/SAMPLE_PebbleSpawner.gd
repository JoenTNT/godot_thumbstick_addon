class_name SAMPLE_PebbleSpawner
extends Node2D

@export var _spawn_area: RectangleShape2D = null;
@export var _pebble_prefab: PackedScene = null;
@export var _pebble_container: Node2D = null;
@export var _initial_amount: int = 24;
@export var _debug_mode: bool = true;

# Runtime variable data.
@onready var _spawned_pebbles: Array[Node2D] = [];
@onready var _rand: RandomNumberGenerator = RandomNumberGenerator.new();
var _min_spawn_point: Vector2;
var _max_spawn_point: Vector2;
var _temp_pebble: Node2D = null;
var _running_in_editor: bool = false;

func _ready() -> void:
	_min_spawn_point = -_spawn_area.size / 2.0;
	_max_spawn_point = -_min_spawn_point;
	var x: float; var y: float;
	for i in range(0, _initial_amount):
		_temp_pebble = _pebble_prefab.instantiate();
		x = _rand.randf_range(_min_spawn_point.x, _max_spawn_point.x);
		y = _rand.randf_range(_min_spawn_point.y, _max_spawn_point.y);
		_pebble_container.add_child(_temp_pebble);
		_temp_pebble.position = Vector2(x, y);

func _process(delta: float) -> void:
	_running_in_editor = Engine.is_editor_hint();
	if !_running_in_editor: return;
	queue_redraw();

func _draw() -> void:
	if !_debug_mode: return;
	var _gizmos_color: Color = Color.WHITE_SMOKE;
	_gizmos_color.a = 0.2;
	draw_rect(Rect2(-_spawn_area.size / 2.0, _spawn_area.size), _gizmos_color);

## Amount of pebbles.
func get_amount() -> int:
	return _spawned_pebbles.size();
