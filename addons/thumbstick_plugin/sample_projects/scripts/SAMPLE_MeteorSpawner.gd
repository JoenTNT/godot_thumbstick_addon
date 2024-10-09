class_name SAMPLE_MeteorSpawner extends Area2D

const MIN_SPAWN_INTERVAL: float = 0.2;

@export var meteor_presets: Array[PackedScene] = [];
@export_range(0.4, 2.0) var max_scale: float = 1.2;
@export var accelerate_spawner_by_second: float = 0.0025;

# Runtime variable data.
@onready var _spawn_area: CollisionShape2D = $"Spawn Area";
@onready var _spawn_timer: Timer = $"Spawn Timer";
var _root: Window;
var _tempSpawnedPreset: Node2D;
var _rect: RectangleShape2D;
var _rand: RandomNumberGenerator;
var _tempPresetIndex: int;
var _origin_spawn_interval: float;
var _current_spawn_interval: float;
var _spawned_meteors: Array[Node2D] = []

func _ready() -> void:
	_rand = RandomNumberGenerator.new();
	_root = get_tree().root;
	_origin_spawn_interval = _spawn_timer.wait_time;
	_current_spawn_interval = _spawn_timer.wait_time;

func spawn_meteor() -> void:
	_rect = _spawn_area.shape as RectangleShape2D;
	var half_size: Vector2 = _rect.size / 2.0;
	var target_pos: Vector2 = Vector2(
		_rand.randf_range(global_position.x - half_size.x, global_position.x + half_size.x),
		_rand.randf_range(global_position.y - half_size.y, global_position.y + half_size.y));
	_tempPresetIndex = _rand.randi_range(0, meteor_presets.size() - 1);
	_tempSpawnedPreset = meteor_presets[_tempPresetIndex].instantiate() as Node2D;
	_root.add_child(_tempSpawnedPreset);
	_tempSpawnedPreset.global_position = target_pos;
	_spawned_meteors.push_back(_tempSpawnedPreset);

func _on_accelerate_spawner() -> void:
	_current_spawn_interval -= accelerate_spawner_by_second;
	if _current_spawn_interval < MIN_SPAWN_INTERVAL:
		_current_spawn_interval = MIN_SPAWN_INTERVAL;
	_spawn_timer.wait_time = _current_spawn_interval;

func get_spawned_meteors() -> Array[Node2D]:
	return _spawned_meteors;

func reset_spawner_accelerator() -> void:
	_spawn_timer.wait_time = _origin_spawn_interval;
	_current_spawn_interval = _origin_spawn_interval;

func clean_up() -> void:
	var sz: int = _spawned_meteors.size();
	for i in range(0, sz):
		_spawned_meteors[i].queue_free();
	_spawned_meteors.clear();
