# MIT License - Copyright (c) 2025 | JoenTNT
# Permission is granted to use, copy, modify, and distribute this file
# for any purpose with or without fee, provided the above notice is included.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

class_name MultiTouchOnDragged
extends Object

## Emitted touch index, used as an identifier.
var finger_index: int;

## Current counted amount of touches that is on screen. 
## The event does not called when the number of touches changed.
var touch_amount: int;
var drag_pos: Vector2;
var drag_dir: Vector2;
var drag_magnitude: float;
