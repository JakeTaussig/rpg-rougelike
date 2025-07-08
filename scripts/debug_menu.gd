extends Control

func _ready() -> void:
	if !get_parent().PROCESS_MODE_PAUSABLE:
		push_warning("warning: parent is not pausable")

	_render_moves_list()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	var paused := not get_tree().paused
	get_tree().paused = paused
	visible = paused

	# TODO: manage focus

func _render_moves_list():
	for move in GameManager.moves_list.moves:
		var button = Button.new()
		button.text = move.move_name
		%MovesList.add_child(button)
