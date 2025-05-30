# MIT License - Copyright (c) 2025 | JoenTNT
# Permission is granted to use, copy, modify, and distribute this file
# for any purpose with or without fee, provided the above notice is included.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

class_name SAMPLE_ScoreUpdater extends RichTextLabel

# Runtime variable data.
@onready var _template_text: String = self.text;

func _ready() -> void:
	_template_text = text;

func set_score_display(score: int) -> void:
	text = _template_text % score;
