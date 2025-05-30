class_name MeditateState
extends BaseState

var last_focused_move_index: int = 0

func enter(_messages: Array = []) -> void:
	_init_move_buttons()
	%Moves.visible = true
	%MovesMenu.get_child(last_focused_move_index).grab_focus()
	
func exit():
	%Moves.visible = false

	for button: Button in %MovesMenu.get_children():
		for dict in button.get_signal_connection_list("pressed"):
			button.disconnect("pressed", dict.callable)
		for dict in button.get_signal_connection_list("focus_entered"):
			button.disconnect("focus_entered", dict.callable)
		for dict in button.get_signal_connection_list("mouse_entered"):
			button.disconnect("mouse_entered", dict.callable)
	
func handle_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		battle.transition_state_to(battle.STATE_SELECTING_ACTION)

func _init_move_buttons():
	for i in %Player.moves.size():
		%MovesMenu.get_child(i).text = %Player.moves[i].move_name
		%MovesMenu.get_child(i).focus_entered.connect(func(): _med_display_pp_info(i))
		var button: Button = %MovesMenu.get_child(i)
		%MovesMenu.get_child(i).pressed.connect(func(): _restore(i))
		
		if %Player.moves[i].pp == %Player.moves[i].max_pp:
			%MovesMenu.get_child(i).set_theme_type_variation("DisabledButton")
		else:
			%MovesMenu.get_child(i).set_theme_type_variation("Button")
		%MovesMenu.get_child(i).mouse_entered.connect(%MovesMenu.get_child(i).grab_focus)

func _restore(i: int):
	var move = %Player.moves[i]
	if move.pp == move.max_pp:
		return
	
	var restore_amt = 3 + (randi() % 3)
	var initial_pp = move.pp
	var restored_pp = min(move.max_pp, initial_pp + restore_amt)
	
	move.pp = restored_pp
		
	battle.transition_state_to(battle.STATE_ATTACKING_INFO, ["%s meditated." % %Player.character_name, ".....", ".......", ".....", "Restored PP of %s from %d to %d." % [%Player.moves[i].move_name, initial_pp, restored_pp]])

func _med_display_pp_info(move_index: int) -> void:
	#last_focused_move_index = move_index
	var move = %Player.moves[move_index]
	
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
