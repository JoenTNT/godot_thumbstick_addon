# MIT License - Copyright (c) 2025 | JoenTNT
# Permission is granted to use, copy, modify, and distribute this file
# for any purpose with or without fee, provided the above notice is included.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

class_name JoystickOnTriggered
extends Object

## Joystick main input directional value that always between 0 to 1.
var input_v: Vector2;

## Current elapsed time in seconds while keep using the joystick.
var elapsed: float;
