@tool
extends EditorPlugin

# Constants.
const MAIN_PANEL = preload("res://addons/thumbstick_plugin/thumbstick.tscn");

# Editor runtime variable data.
var _main_panel_instance: Control = null;

func _enter_tree() -> void:
	_main_panel_instance = MAIN_PANEL.instantiate();
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, _main_panel_instance);

func _exit_tree() -> void:
	remove_control_from_docks(_main_panel_instance);
	_main_panel_instance.queue_free();
