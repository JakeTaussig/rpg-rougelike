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
	%MovesList.get_child(0).queue_free()

	for move in GameManager.moves_list.moves:
		var button = Button.new()
		button.text = move.move_name
		%MovesList.add_child(button)

		# TODO: display addtl. info when move is hovered
		#button.focus_entered.connect(func(): _display_pp_info(i))
		button.mouse_entered.connect(button.grab_focus)
		button.pressed.connect(func(): _on_debug_move_pressed(move))


func _on_debug_move_pressed(move: Move):
	print("\tuser input (DEBUG):\t\tselect DEBUG move %s" % [move.move_name])
	if move.pp > 0:
		var attackCommand = AttackState.AttackCommand.new()
		attackCommand.attacker = GameManager.player.selected_monster
		attackCommand.move_index = -1
		attackCommand._debug_move = move
		attackCommand.target = GameManager.enemy.selected_monster
		GameManager.current_battle.transition_state_to(GameManager.current_battle.STATE_ATTACK, [attackCommand])
		toggle_pause()
