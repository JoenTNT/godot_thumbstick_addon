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

## Current dragging global position at.
var drag_pos: Vector2;

## Current dragging local position at gui space.
var local_drag_pos: Vector2;

## Dragging direction from previous point to current point which has been normalized.
var normal_drag_dir: Vector2;

## Magnitude distance between previous dragged position to current one.
var drag_magnitude: float;
