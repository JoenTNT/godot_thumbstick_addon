# MIT License - Copyright (c) 2025 | JoenTNT
# Permission is granted to use, copy, modify, and distribute this file
# for any purpose with or without fee, provided the above notice is included.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

class_name MultiTouchOnMaxChanged
extends Object

# Properties.
## The old amount of maximum touch previously.
var old_amount: int;

## The new amount of modified maximum touches.
var new_amount: int;

## When max amount changed, how much touch was triggered before change.
var touch_triggered: int;
