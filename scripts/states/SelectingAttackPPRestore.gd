extends SelectingAttack

func _render_moves():
	for i in %Player.selected_monster.moves.size():
		var move = %Player.selected_monster.moves[i]
		if move.pp == move.max_pp:
			%MovesMenu.get_child(i).set_theme_type_variation("DisabledButton")
		else:
			%MovesMenu.get_child(i).set_theme_type_variation("Button")

func _init_move_buttons():
	for i in %Player.selected_monster.moves.size():
		%MovesMenu.get_child(i).text = %Player.selected_monster.moves[i].move_name
		%MovesMenu.get_child(i).focus_entered.connect(func(): _display_pp_info(i))
		%MovesMenu.get_child(i).pressed.connect(func(): _restore(i))

		if %Player.selected_monster.moves[i].pp == %Player.selected_monster.moves[i].max_pp:
			%MovesMenu.get_child(i).set_theme_type_variation("DisabledButton")
		else:
			%MovesMenu.get_child(i).set_theme_type_variation("Button")
		%MovesMenu.get_child(i).mouse_entered.connect(%MovesMenu.get_child(i).grab_focus)

func _restore(i: int):
	var move = %Player.selected_monster.moves[i]
	if move.pp == move.max_pp:
		return

	var restore_amt = 3 + (randi() % 3)
	var initial_pp = move.pp
	var restored_pp = min(move.max_pp, initial_pp + restore_amt)

	move.pp = restored_pp

	battle.transition_state_to(battle.STATE_INFO, ["%s meditated." % %Player.selected_monster.character_name, ".....", ".......", ".....", "Restored PP of %s from %d to %d." % [%Player.selected_monster.moves[i].move_name, initial_pp, restored_pp]])

func _display_pp_info(move_index: int) -> void:
	#last_focused_move_index = move_index
	var move = %Player.selected_monster.moves[move_index]

	var min_updated_pp = min(move.max_pp, move.pp + 3)
	var max_updated_pp = min(move.max_pp, move.pp + 5)

	if move.pp == move.max_pp:
		%PPInfo.text = "%d / %d" % [move.pp, move.max_pp]
		%TypeInfo.text = "PP Already full"
		%PPInfo.set_theme_type_variation("GrayTextLabel")
		%TypeInfo.set_theme_type_variation("GrayTextLabel")
		return
	elif min_updated_pp == max_updated_pp:
		%PPInfo.text = "%d --> %d" % [move.pp, min_updated_pp]
	else:
		%PPInfo.text = "%d -->  %d - %d" % [move.pp, min_updated_pp, max_updated_pp]

	%PPInfo.set_theme_type_variation("NoBorderLabel")
	%TypeInfo.set_theme_type_variation("NoBorderLabel")
	%TypeInfo.text = "Restore\nup to 5 PP"

func _on_move_pressed(index: int) -> void:
	var move = %Player.selected_monster.moves[index]
	print("\tuser input:\t\tselect %s (idx %d)" % [move.move_name, index])
	if move.pp < move.max_pp:
		battle.transition_state_to(
			battle.STATE_INFO, [])

func handle_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		battle.transition_state_to(battle.STATE_SELECTING_ITEM, ["replenish"])
