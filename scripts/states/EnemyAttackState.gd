extends BaseState

func enter(messages: Array = []):
	var enemy = battle_system.get_current_attacker()
	var enemyMoveIdx = enemy.select_move()
	if enemyMoveIdx != -1:
		battle_system.attack(enemyMoveIdx, %Player)
	else:
		battle_system.transition_state_to("ATTACKING_INFO", ["%s can't attack" % enemy.character_name])
