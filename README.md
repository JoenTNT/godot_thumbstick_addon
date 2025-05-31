# Godot Thumbstick Plugin - Easy Mobile Controller Module

<div align=center>
	<img src="/addons/thumbstick_plugin/plugin/plugin_icon.png" style="width: 128px; height: auto;">
</div>

<div align=center>
    <img src="https://img.shields.io/badge/version-%31%2E%31-green">
    <a href="./LICENSE">
        <img src="https://img.shields.io/badge/LICENSE-MIT-blue">
    </a>
    <br>
    <img src="https://img.shields.io/badge/GD_Script-468cbf">
    <img src="https://img.shields.io/badge/4.3-468cbf">
    <img src="https://img.shields.io/badge/4.4-468cbf">
</div>

---

> A __Single Scripted__ and <ins>(yet) __most convenient__</ins> mobile controller setup element and connector. This plugin included presets and detailed debug information mainly used for easy mobile controller setup validation.

<div align=center>
    <img src="/addons/thumbstick_plugin/sample_projects/screenshots/preview_joysticks.png">
</div>

## PLUGIN FEATURES

- [**Virtual Joystick**](#a-virtual-joysticks-controller), an usual mobile controller, just drag and drop into your scene (Presets include *`Normal`*, *`Horizontal Only`*, and *`Vertical Only`*).
- [**Multitouch**](#b-multitouch-controller), an area where it detects multiple touches and motions.
- **Point & Snap**, a simple press the point, drag, and snap to other points (COMING SOON).
- **Coloring Style**, changing color based on controller actions.
- **Quick Debug Gizmos**, immediately visualize touch screen controller setup, just activate *`Debug Mode`* in inspector property.
- **Quick Target Controller Setup**, insert your player node into *`Control Target Node`* property and assign all functions.
- **Complete Setting Up Properties**, everything you need for setting up screen controller.

## How to Install?

You can either download via **Asset Library** available in Godot Engine, or Download from Releases [here](https://github.com/JoenTNT/godot_thumbstick_addon/releases/) and follow these steps:

1. Download Thumbstick Plugin `ZIP` file.
2. Extract files from the `ZIP` file.
3. Copy `thumbstick_plugin` folder and place it in your Godot Project `addons` folder. (If you haven't added the `addons` folder under the `res://` folder, then create the folder first)

## QUICK DOCUMENTATION

> This Documentation has been updated since **16 October 2024**.
> May be updated in the future for more tools and features.

### **A. VIRTUAL JOYSTICKS CONTROLLER**

> A single scripted mobile joystick controller.

Normally determined as a single circular controller that can be moved in 2 axis direction placed in user interface screen. It only detects one finger touch and will ignore other touch impacting the control area.

You can manually customize yourself by editing or duplicating presets available in `addons` -> `thumbstick_plugin` -> `plugin` -> `controllers` folder.

---

<div align=center>
    <img src="/addons/thumbstick_plugin/sample_projects/screenshots/properties_1.png" height=410px/>
    <img src="/addons/thumbstick_plugin/sample_projects/screenshots/properties_2.png" height=410px/>
</div>

---

### List of Properties

1. `Mode`, Settings joystick behavior between `Static`, `Dynamic`, or `Follow`.
    - `Static`, Joystick doesn't move, it will always at dev setup position on screen.
        - Additional Settings : `Extend Static Area Trigger`, Extends rectangular static touch trigger area for joystick static mode.
    - `Dynamic`, Every time the joystick area is pressed, the joystick position is set on the touched position.
    - `Follow`, When the finger moves outside the joystick area, the joystick will follow it.
        - Additional Settings : `Follow Radius Tolerance`, Extra radius in joystick follow mode to prevents joystick display move until exceeds this tolerance.
2. `Input Mode`, input mode based on direction input limitation.
    - `Normal`, This is the default 2 axis direction joystick input.
    - `Horizontal Only`, Joystick can be moved only horizontally.
    - `Vertical Only`, Joystick can be moved only vertically.

---

### **B. MULTITOUCH CONTROLLER**

<div align=center>
    <img src="/addons/thumbstick_plugin/sample_projects/screenshots/multitouch_controller_preview.png"/>
</div>

---

> A single scripted controller that accepts multiple touches.

One single control node can handle multiple touch control, that's the definition for this module. Each touch will have it's finger index as an identifier. You can limit and manipulate how much touches will be process in gameplay.

<div align=center>
    <img src="/addons/thumbstick_plugin/sample_projects/screenshots/finger-picker-test-preview.png"/>
</div>

You can manually customize yourself by editing or duplicating presets available in `addons` -> `thumbstick_plugin` -> `plugin` -> `controllers` folder.

---
# PATCH LOGS

```
### Version 1.2.0 ###
- Fixed Multitouch Controller Minor Bugs.
- Updated Multitouch Controller, you can now manipulate maximum finger amount in runtime.
- All event arguments now contains global and local position.
- Controller is completely GUI-based, you can now block the controller using UI element.
```

```
### Version 1.1.1 ###
- Multitouch Controller maximum amount of touch now can be manipulated at runtime.
```

```
### Version 1.1.0 ###
- Added a single scripted Multitouch Controller
- Added Sample Project "Finger Choice"
- IMPORTANT: Parameter events are now using custom class arguments
  - For those who installed previous version will have some minor changes
  - Example: on_pressed(press_position: Vector2) -> on_pressed(args: JoystickOnPressed)
```

```
### Version 1.0.3 ###
- Initial Released for Godot 4.3
- Added Joystick Controller
```