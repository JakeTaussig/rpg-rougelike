extends BaseState

func enter(messages: Array = []):
	var enemy = battle.get_current_attacker()
	var enemyMoveIdx = enemy.select_move()
	if enemyMoveIdx != -1:
		var attackCommand = AttackState.AttackCommand.new()
		attackCommand.attacker = enemy
		attackCommand.move_index = enemyMoveIdx
		attackCommand.target = %Player
		battle.transition_state_to(
			battle.STATE_ATTACK, battle.STATE_ENEMY_ATTACK,
			[attackCommand])
	else:
		battle.transition_state_to(battle.STATE_INFO, battle.STATE_ENEMY_ATTACK, ["%s can't attack" % enemy.character_name])
