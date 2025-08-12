extends BaseState


func enter(messages: Array = []):
	battle.ui_manager.show_player_prompt(true)
	battle.ui_manager.show_action_menu(true)
	battle.ui_manager.focus_action_button()

	for button: Button in battle.ui_manager.get_action_buttons():
		button.mouse_entered.connect(button.grab_focus)

	if messages.size() == 0:
		battle.ui_manager.set_player_prompt("What will %s do?" % GameManager.player.selected_monster.character_name)
	else:
		battle.ui_manager.set_player_prompt(messages[0])


func exit():
	for button: Button in battle.ui_manager.get_action_buttons():
		button.mouse_entered.disconnect(button.grab_focus)

	battle.ui_manager.show_player_prompt(false)
	battle.ui_manager.show_action_menu(false)


func _on_attack_pressed() -> void:
	battle.transition_state_to(battle.STATE_SELECTING_ATTACK)

# No longer functional - this button will likely be removed anyway.
#func _on_tracker_pressed() -> void:
#battle.get_node("Trackers/PlayerTracker").populate_player_tracker()
#battle.get_node("Trackers/EnemyTracker").populate_enemy_tracker()
#battle.get_node("Trackers").visible = not battle.get_node("Trackers").visible
