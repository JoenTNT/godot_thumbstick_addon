# MIT License - Copyright (c) 2025 | JoenTNT
# Permission is granted to use, copy, modify, and distribute this file
# for any purpose with or without fee, provided the above notice is included.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

class_name SAMPLE_BackgroundHoleSetter
extends Sprite2D

# Properties.
@export var _duration: float = 1.5:
	set(d):
		if d < 0.001: return;
		_duration = d;
@export var _radius_param: StringName = &"radius";
@export var _background_tint_param: StringName = &"bg_tint";
## Left is growth value, Right is shrink value.
@export var _tweener: Curve = null;
@export var _shrink_on_start: bool = false;

# Runtime variable data.
var _duped_mat: ShaderMaterial = null;
var _tvalue: float = 0.0;
var _do_shrink_tween: bool = false;
var _result: float = 0.0;

func _ready() -> void:
	_duped_mat = material.duplicate(true);
	material = _duped_mat;
	_do_shrink_tween = _shrink_on_start;
	if _do_shrink_tween:
		_tvalue = _duration;
		_duped_mat.set_shader_parameter(_radius_param, _tweener.sample(1.0));
	else:
		_duped_mat.set_shader_parameter(_radius_param, _tweener.sample(0.0));

func _process(delta: float) -> void:
	if _do_shrink_tween:
		if _tvalue >= _duration: return;
		_tvalue += delta;
		_result = _tweener.sample(_tvalue / _duration);
		_duped_mat.set_shader_parameter(_radius_param, _result);
	else:
		if _tvalue <= 0.0: return;
		_tvalue -= delta;
		_result = _tweener.sample(_tvalue / _duration);
		_duped_mat.set_shader_parameter(_radius_param, _result);

func shrink_hole() -> void:
	_do_shrink_tween = true;

func grow_hole() -> void:
	_do_shrink_tween = false;

func is_shrunked() -> bool:
	return _do_shrink_tween;

func set_outer_color(c: Color) -> void:
	_duped_mat.set_shader_parameter(_background_tint_param, c);
