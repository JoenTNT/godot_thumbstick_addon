class_name SAMPLE_ScoreEmitter extends Area2D

@export var score_display: SAMPLE_ScoreUpdater = null;
@export var initial_score_set: int = 0;
@export var increament_per_emit: int = 100;

# Runtime variable data.
var _current_score: int = 0;

func _ready() -> void:
	_current_score = initial_score_set;
	score_display.call_deferred("set_score_display", _current_score);

func _on_increase_score(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	_current_score += increament_per_emit;
	score_display.set_score_display(_current_score);

func reset_score() -> void:
	_current_score = initial_score_set;
	score_display.set_score_display(_current_score);
