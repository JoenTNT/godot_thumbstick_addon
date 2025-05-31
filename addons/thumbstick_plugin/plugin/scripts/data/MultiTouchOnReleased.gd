# MIT License - Copyright (c) 2025 | JoenTNT
# Permission is granted to use, copy, modify, and distribute this file
# for any purpose with or without fee, provided the above notice is included.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

class_name MultiTouchOnReleased
extends Object

## Emitted touch index, used as an identifier.
var finger_index: int;

## Current counted amount of touches that is on screen.
var touch_amount: int;

## Global position of last finger point released from screen.
var latest_position: Vector2;

## Local position in gui space of last finger point released from screen.
var local_latest_position: Vector2;
