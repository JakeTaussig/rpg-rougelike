extends SelectingAttack

func _render_moves():
	var move_buttons = battle.ui_manager.get_move_buttons()
	for i in GameManager.player.selected_monster.moves.size():
		var move = GameManager.player.selected_monster.moves[i]
		var enabled = move.pp < move.max_pp
		battle.ui_manager.set_button_style_enabled(move_buttons[i], enabled)

func _init_move_buttons():
	var move_buttons = battle.ui_manager.get_move_buttons()
	for i in GameManager.player.selected_monster.moves.size():
		move_buttons[i].text = GameManager.player.selected_monster.moves[i].move_name
		move_buttons[i].focus_entered.connect(func(): _display_pp_info(i))
		move_buttons[i].mouse_entered.connect(move_buttons[i].grab_focus)
		move_buttons[i].pressed.connect(func(): _restore(i))

	for i in GameManager.player.selected_monster.moves.size():
		var move = GameManager.player.selected_monster.moves[i]
		if move.pp == move.max_pp:
			move_buttons[i].set_theme_type_variation("DisabledButton")
		else:
			move_buttons[i].set_theme_type_variation("Button")

func _restore(i: int):
	var move = GameManager.player.selected_monster.moves[i]
	if move.pp == move.max_pp:
		return

	var restore_amt = 3 + (randi() % 3)
	var initial_pp = move.pp
	var restored_pp = min(move.max_pp, initial_pp + restore_amt)

	move.pp = restored_pp

	battle.transition_state_to(battle.STATE_INFO, ["%s meditated." % GameManager.player.selected_monster.character_name, ".....", ".......", ".....", "Restored PP of %s from %d to %d." % [GameManager.player.selected_monster.moves[i].move_name, initial_pp, restored_pp]])

func _display_pp_info(move_index: int) -> void:
	#last_focused_move_index = move_index
	var move = GameManager.player.selected_monster.moves[move_index]

	var min_updated_pp = min(move.max_pp, move.pp + 3)
	var max_updated_pp = min(move.max_pp, move.pp + 5)
	var min_added_pp = min_updated_pp - move.pp
	var max_added_pp = max_updated_pp - move.pp

	if move.pp == move.max_pp:
		battle.ui_manager.set_pp_info("%d / %d" % [move.pp, move.max_pp], true)
		battle.ui_manager.set_type_info("PP Already full", true)
		return
	elif min_added_pp == max_added_pp:
		battle.ui_manager.set_pp_info("%d --> %d" % [move.pp, min_updated_pp], false)
		battle.ui_manager.set_type_info("Restore %d PP" % [min_added_pp], false)
	else:
		battle.ui_manager.set_pp_info("%d -->  %d - %d" % [move.pp, min_updated_pp, max_updated_pp], false)
		battle.ui_manager.set_type_info("Restore %d-%d PP" % [min_added_pp, max_added_pp] % [min_added_pp], false)


func _on_move_pressed(index: int) -> void:
	var move = GameManager.player.selected_monster.moves[index]
	print("\tuser input:\t\tselect %s (idx %d)" % [move.move_name, index])
	if move.pp < move.max_pp:
		battle.transition_state_to(battle.STATE_INFO, [])

func handle_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		battle.transition_state_to(battle.STATE_SELECTING_ITEM, ["replenish"])
