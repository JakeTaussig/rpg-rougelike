extends BaseState

func enter(_messages: Array = []):
	if _is_battle_over():
		battle.transition_state_to(battle.STATE_GAME_END)
		return
	elif _is_current_enemy_defeated():
		pass
		
	battle.turn_order_index = (battle.turn_order_index + 1) % battle.battle_participants.size()
	if battle.turn_order_index == 0:
		battle.turn += 1
		_log_turn_info()

	%TurnDisplay.text = "trn: %s idx: %s" % [battle.turn, battle.turn_order_index]

	if battle.battle_participants[battle.turn_order_index].is_player:
		battle.transition_state_to(battle.STATE_SELECTING_ACTION)
	else:
		battle.transition_state_to(battle.STATE_ENEMY_ATTACK)

func _is_battle_over() -> bool:
	#TODO: Add some condition here which checks if all enemies have been defeated. 
	return battle.get_node("%Player").monster.hp <= 0

func _is_current_enemy_defeated():
	pass

func _log_turn_info():
	print("---------------------------")
	print("Turn: %d" % battle.turn)
	print("---------------------------")
