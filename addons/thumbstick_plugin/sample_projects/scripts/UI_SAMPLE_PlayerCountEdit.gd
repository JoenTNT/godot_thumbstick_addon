# MIT License - Copyright (c) 2025 | JoenTNT
# Permission is granted to use, copy, modify, and distribute this file
# for any purpose with or without fee, provided the above notice is included.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

class_name UI_SAMPLE_PlayerCountEdit
extends Control

# Requirements.
@export var _up_btn: BaseButton = null;
@export var _down_btn: BaseButton = null;
@export var _multitouch: UI_MultiTouchController = null;
@export var _text_hint: RichTextLabel = null;

# Runtime variable data.
var _text_hint_str: String = "";
var _current_max_amount: int = 0;

func _enter_tree() -> void:
	# Subscribe events.
	_up_btn.pressed.connect(_on_up_button);
	_down_btn.pressed.connect(_on_down_button);

func _exit_tree() -> void:
	# Unsubscribe events.
	_up_btn.pressed.disconnect(_on_up_button);
	_down_btn.pressed.disconnect(_on_down_button);

func _ready() -> void:
	_current_max_amount = _multitouch.get_max_touch_amount();
	_text_hint_str = _text_hint.text;
	_text_hint.text = _text_hint_str % _current_max_amount;

func _on_up_button() -> void:
	_current_max_amount += 1;
	_multitouch.set_max_touch_amount(_current_max_amount);
	_text_hint.text = _text_hint_str % _current_max_amount;

func _on_down_button() -> void:
	_current_max_amount -= 1;
	if _current_max_amount < 0:
		_current_max_amount = 0;
		return;
	_multitouch.set_max_touch_amount(_current_max_amount);
	_text_hint.text = _text_hint_str % _current_max_amount;
