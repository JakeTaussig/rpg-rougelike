extends Label

# value is in pixels -- this means the right edge of the label is at least 7
# pixels away from the edge of the window
const BUFFER: int = 7
var _initialized: bool = false

func _ready():
	call_deferred("adjust_position")

func adjust_position():
	var viewport_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var viewport_scale: int = ProjectSettings.get_setting("display/window/stretch/scale")
	var viewport_pixel_width: int = viewport_width / viewport_scale

	var label_right_edge: int = position.x + size.x
	var overflow: int = (label_right_edge - viewport_pixel_width) + BUFFER

	if overflow > 0:
		position.x -= overflow
