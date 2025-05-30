# MIT License - Copyright (c) 2025 | JoenTNT
# Permission is granted to use, copy, modify, and distribute this file
# for any purpose with or without fee, provided the above notice is included.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

class_name JoystickOnReleased
extends Object

## Exact released point global position.
var release_position: Vector2;

## Exact released point local position inside the ui-based space.
var local_release_position: Vector2;

## Time in seconds that has been elapsed after released the joystick.
var elapsed: float
