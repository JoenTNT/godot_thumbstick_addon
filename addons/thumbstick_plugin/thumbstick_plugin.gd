@tool
extends EditorPlugin

# Constants.
const MAIN_PANEL = preload("res://addons/thumbstick_plugin/thumbstick.tscn");

# Editor runtime variable data.
var _main_panel_instance: Control = null;
#var _editor_inspector_button_plugin: InspectorButton = null;

func _enter_tree() -> void:
	_main_panel_instance = MAIN_PANEL.instantiate();
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, _main_panel_instance);
	#_editor_inspector_button_plugin = InspectorButton.new();
	#add_inspector_plugin(_editor_inspector_button_plugin);

func _exit_tree() -> void:
	remove_control_from_docks(_main_panel_instance);
	_main_panel_instance.queue_free();
	#if is_instance_valid(_editor_inspector_button_plugin):
		#remove_inspector_plugin(_editor_inspector_button_plugin);
		#_editor_inspector_button_plugin = null;

# TODO: Add a button to activate and deactivate debug mode.
#class InspectorButton extends EditorInspectorPlugin:
	#
	#func _can_handle(object: Object) -> bool:
		#return object.has_method('_add_inspector_buttons')
	#
	#func _parse_begin(object: Object) -> void:
		#var buttons_data = object._add_inspector_buttons()
		#for button_data in buttons_data:
			#var name = button_data.get("name", null)
			#var icon = button_data.get("icon", null)
			#var pressed = button_data.get("pressed", null)
			#if not name:
				#push_warning('_add_inspector_buttons(): A button does 
					#not have a name key. Defaulting to: "Button"')
				#name = "Button"
			#if icon and not icon is Texture:
				#push_warning('_add_inspector_buttons(): The button 
					#<{name}> icon is not a texture.'.format({"name":name}))
				#icon = null
			#if not pressed:
				#push_warning('_add_inspector_buttons(): The button 
					#<{name}> does not have a pressed key. Skipping.'.format({"name":name}))
				#continue
			#if not pressed is Callable:
				#push_warning('_add_inspector_buttons(): The button 
					#<{name}> pressed is not a Callable. Skipping.'.format({"name":name}))
				#continue
			#var button = Button.new()
			#button.text = name
			#if icon:
				#button.icon = icon
				#button.expand_icon = true
			#button.pressed.connect(pressed)
			#add_custom_control(button)
