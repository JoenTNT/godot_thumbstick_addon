# MIT License - Copyright (c) 2025 | JoenTNT
# Permission is granted to use, copy, modify, and distribute this file
# for any purpose with or without fee, provided the above notice is included.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

class_name MultiTouchOnPressed
extends Object

## Emitted touch index, used as an identifier.
var finger_index: int;

## Current counted amount of touches that is on screen.
var touch_amount: int;

## Specific on pressed global position.
var pressed_position: Vector2;

## Specific on pressed local position in gui space.
var local_pressed_position: Vector2;
