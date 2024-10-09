class_name SAMPLE_PlayerBall3DControl extends RigidBody3D

@export var torque_speed: float = 12.0;

# Runtime variable data.
var _roll_direction: Vector2;
var _is_moving: bool = false;

func _process(delta: float) -> void:
	angular_velocity = Vector3(_roll_direction.y, 0.0,
		-_roll_direction.x) * torque_speed;

func _on_trigger(input_v: Vector2, elapsed: float) -> void:
	_roll_direction = input_v;

func _on_released(releasePosition: Vector2, elapsed: float) -> void:
	_is_moving = false;
	_roll_direction = Vector2.ZERO;

func _on_pressed(pressPosition: Vector2) -> void:
	_is_moving = true;
