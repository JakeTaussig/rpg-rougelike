extends Button


func _ready():
	mouse_entered.connect(grab_focus)


func _pressed():
	var cancel_event = InputEventAction.new()
	cancel_event.action = "ui_cancel"
	cancel_event.pressed = true
	Input.parse_input_event(cancel_event)
