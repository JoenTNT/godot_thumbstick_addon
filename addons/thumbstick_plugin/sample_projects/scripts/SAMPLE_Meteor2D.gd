class_name SAMPLE_Meteor2D extends Area2D

@export var min_drop_velocity: float = 72.0;
@export var max_drop_velocity: float = 144.0;
@export_range(0.0, 1080.0) var max_initial_angular_velocity: float = 180.0;

# Runtime variable data.
var _rand: RandomNumberGenerator;
var _drop_velocity: Vector2 = Vector2.ZERO;
var _constant_angular_velocity: float = 0.0;

func _ready() -> void:
	_rand = RandomNumberGenerator.new();
	_drop_velocity = Vector2(0.0,
		_rand.randf_range(min_drop_velocity, max_drop_velocity));
	_constant_angular_velocity = _rand.randf_range(
		-max_initial_angular_velocity, max_initial_angular_velocity)

func _process(delta: float) -> void:
	position += _drop_velocity * delta;
	rotation_degrees += _constant_angular_velocity * delta;

func _on_body_entered(body: Node2D) -> void:
	set_deferred(&"monitoring", false);
	set_deferred(&"monitoring", true);
	if body.has_method("_on_destroyed"):
		body._on_destroyed(self);
