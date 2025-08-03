extends BaseState
class_name SelectingAttack

var last_focused_move_index: int = 0


func enter(_messages: Array = []):
	_init_move_buttons()
	battle.ui_manager.show_moves_menu(true)
	battle.ui_manager.get_move_buttons()[last_focused_move_index].grab_focus()


func exit():
	battle.ui_manager.show_moves_menu(false)
	for button: Button in battle.ui_manager.get_move_buttons():
		for dict in button.get_signal_connection_list("pressed"):
			button.disconnect("pressed", dict.callable)
		for dict in button.get_signal_connection_list("focus_entered"):
			button.disconnect("focus_entered", dict.callable)
		for dict in button.get_signal_connection_list("mouse_entered"):
			button.disconnect("mouse_entered", dict.callable)


func handle_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		battle.transition_state_to(battle.STATE_SELECTING_ACTION)


func _on_move_pressed(index: int) -> void:
	var move = GameManager.player.selected_monster.moves[index]
	print("\tuser input:\t\tselect %s (idx %d)" % [move.move_name, index])
	if move.pp > 0:
		var attackCommand = AttackState.AttackCommand.new()
		attackCommand.attacker = GameManager.player.selected_monster
		attackCommand.target = GameManager.enemy.selected_monster
		attackCommand.move = GameManager.player.selected_monster.moves[index]
		battle.transition_state_to(battle.STATE_ATTACK, [attackCommand])


# initialize move names and connect PP info display
func _init_move_buttons():
	var move_buttons = battle.ui_manager.get_move_buttons()
	for i in GameManager.player.selected_monster.moves.size():
		var move = GameManager.player.selected_monster.moves[i]

		move_buttons[i].text = move.move_name
		move_buttons[i].focus_entered.connect(func(): _display_pp_info(i))
		move_buttons[i].mouse_entered.connect(move_buttons[i].grab_focus)
		move_buttons[i].pressed.connect(func(): _on_move_pressed(i))

		if move.pp <= 0:
			move_buttons[i].set_theme_type_variation("DisabledButton")
		else:
			move_buttons[i].set_theme_type_variation("Button")


# callback used when a move is focused
# displays the PP and type of the move in $"Moves/MovesInfo"
func _display_pp_info(move_index: int) -> void:
	last_focused_move_index = move_index

	var move = GameManager.player.selected_monster.moves[move_index]

	var text = "%d / %d" % [move.pp, move.max_pp]
	var disabled: bool = move.pp <= 0
	battle.ui_manager.set_pp_info(text, disabled)

	battle.ui_manager.set_type_info(move.type, disabled)
	battle.ui_manager.set_move_power(move.base_power, disabled)
	battle.ui_manager.set_move_accuracy(move.acc, disabled)
