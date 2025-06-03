extends BaseState

func enter(_messages: Array = []):
	if _is_battle_over():
		battle.transition_state_to(battle.STATE_GAME_END)
		return

	battle.turn_order_index = (battle.turn_order_index + 1) % battle.active_monsters.size()
	if battle.turn_order_index == 0:
		battle.turn += 1
		_log_turn_info()

	%TurnDisplay.text = "trn: %s idx: %s" % [battle.turn, battle.turn_order_index]

	print(battle.turn_order_index)
	if battle.active_monsters[battle.turn_order_index].is_player:
		battle.transition_state_to(battle.STATE_SELECTING_ACTION)
	else:
		battle.transition_state_to(battle.STATE_ENEMY_ATTACK)

# TODO: in another branch - only trigger battle over if the player is dead or the enemy is out of Monsters.
func _is_battle_over() -> bool:
	return %Enemy.selected_monster.hp <= 0 || %Player.selected_monster.hp <= 0

func _log_turn_info():
	print("---------------------------")
	print("Turn: %d" % battle.turn)
	print("---------------------------")
