extends BaseState

var _initialized = false

func enter(_messages: Array = []):
	if _is_battle_over():
		battle.transition_state_to(Battle.State.GAME_END)
		return

	battle.turn_order_index = (battle.turn_order_index + 1) % battle.battle_participants.size()
	if battle.turn_order_index == 0:
		battle.turn += 1
		_log_turn_info()

	%TurnDisplay.text = "trn: %s idx: %s" % [battle.turn, battle.turn_order_index]

	if battle.battle_participants[battle.turn_order_index].is_player:
		battle.transition_state_to(battle.State.SELECTING_ACTION)
	else:
		battle.transition_state_to(battle.State.ENEMY_ATTACK)

func _is_battle_over() -> bool:
	return battle.enemies[0].hp <= 0 || battle.get_node("%Player").hp <= 0

func _log_turn_info():
	print("---------------------------")
	print("Turn: %d" % battle.turn)
	print("---------------------------")
