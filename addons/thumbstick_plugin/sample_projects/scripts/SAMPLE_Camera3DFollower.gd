# MIT License - Copyright (c) 2025 | JoenTNT
# Permission is granted to use, copy, modify, and distribute this file
# for any purpose with or without fee, provided the above notice is included.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

class_name SAMPLE_Camera3DFollower
extends Camera3D

@export var target_follow: Node3D = null;
@export var follow_offset: Vector3 = Vector3.ZERO;

# Runtime variable data.
var _expected_position: Vector3;

func _process(_delta: float) -> void:
	if target_follow == null: return;
	_expected_position = target_follow.global_position + follow_offset;
	position = _expected_position;
