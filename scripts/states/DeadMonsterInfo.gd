class_name DeadMonsterInfoState
extends InfoState

# DeadMonsterInfoState Inherits from InfoState. We need this state so that we
# can block the continiue button while a monster's death animation plays


func enter(_messages: Array = []):
	battle.ui_manager.render_battlers()
	battle.ui_manager.show_info_panel(true)
	battle.ui_manager.focus_continue_button()
	messages = _messages
	message_index = 0
	_update_message()

	# Block continue button while death animation is running.
	GameManager.current_battle.ui_manager.disable_continue_button()
	await play_death_animations()
	GameManager.current_battle.ui_manager.enable_continue_button()

	if messages.size() == 0:
		print("\tno messages; skipping INFO state")
		handle_continue()


func play_death_animations():
	var player = GameManager.player
	var enemy = GameManager.enemy

	if enemy.selected_monster.hp <= 0:
		await enemy.play_death_animation()
	if player.selected_monster.hp <= 0:
		await player.play_death_animation()
