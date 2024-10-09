class_name SAMPLE_Destroyer2D extends Area2D

@export var spawner_container: SAMPLE_MeteorSpawner = null;

# Runtime variable data.
var _container_reference: Array[Node2D];

func _on_area_trigger_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	set_deferred(&"monitoring", false);
	set_deferred(&"monitoring", true);
	_container_reference = spawner_container.get_spawned_meteors();
	var index: int = _container_reference.find(area);
	if index >= 0: _container_reference.remove_at(index);
	area.call_deferred("queue_free");
