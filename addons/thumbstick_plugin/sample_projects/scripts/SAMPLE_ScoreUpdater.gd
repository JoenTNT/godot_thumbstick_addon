class_name SAMPLE_ScoreUpdater extends RichTextLabel

# Runtime variable data.
@onready var _template_text: String = self.text;

func _ready() -> void:
	_template_text = text;

func set_score_display(score: int) -> void:
	text = _template_text % score;
