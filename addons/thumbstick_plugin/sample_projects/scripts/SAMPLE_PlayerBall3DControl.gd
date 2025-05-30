# MIT License - Copyright (c) 2025 | JoenTNT
# Permission is granted to use, copy, modify, and distribute this file
# for any purpose with or without fee, provided the above notice is included.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

class_name SAMPLE_PlayerBall3DControl
extends RigidBody3D

# Properties.
@export var torque_speed: float = 12.0;

# Runtime variable data.
var _roll_direction: Vector2;
var _is_moving: bool = false;

func _process(delta: float) -> void:
	angular_velocity = Vector3(_roll_direction.y, 0.0, -_roll_direction.x) * torque_speed;

func _on_pressed(_args: JoystickOnPressed) -> void:
	_is_moving = true;

func _on_released(_args: JoystickOnReleased) -> void:
	_is_moving = false;
	_roll_direction = Vector2.ZERO;

func _on_trigger(args: JoystickOnTriggered) -> void:
	_roll_direction = args.input_v;
