class_name THUMMBSTICK_CONSTANTS

## Joystick doesn't move, it will always at dev setup position on screen.
const TJC_MODE_STATIC: String = "Static";

## Every time the joystick area is pressed, 
## the joystick position is set on the touched position.
const TJC_MODE_DYNAMIC: String = "Dynamic";

## When the finger moves outside the joystick area, 
## the joystick will follow it.
const TJC_MODE_FOLLOW: String = "Follow"

## Joystick always visible.
const TJC_VISIBILITY_ALWAYS: String = "Always";

## Only visible when touching then screen.
const TJC_VISIBILITY_TOUCHSCREEN: String = "Touchscreen";

## Joystick Input has been completely disabled.
## This mode disabled all the events including press and release input.
## NOTE: Has been removed and replaced to editable status joystick.
##const TJC_INPUT_DISABLED: String = "Disabled";

## Joystick cannot be moved but tap only input.
## This mode does not disabled preesed and released input.
## NOTE: Has been removed and replaced to controller setting enable tap trigger
##const TJC_INPUT_TAPONLY: String = "Tap Only";

## Joystick can be moved only horizontally.
const TJC_INPUT_HORIZONTALONLY: String = "Horizontal Only";

## Joystick can be moved only vertically.
const TJC_INPUT_VERTICALONLY: String = "Vertical Only";

## This is the default 2 axis direction joystick input.
const TJC_INPUT_NORMAL: String = "Normal";
