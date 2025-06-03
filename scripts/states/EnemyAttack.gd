extends BaseState

func enter(_messages: Array = []):
	var enemy = battle.get_current_attacker()
	var enemyMoveIdx = enemy.select_move()
	if enemyMoveIdx != -1:
		var attackCommand = AttackState.AttackCommand.new()
		attackCommand.attacker = enemy
		attackCommand.move_index = enemyMoveIdx
		attackCommand.target = %Player
		battle.transition_state_to(
			battle.STATE_ATTACK, [attackCommand])
	else:
		battle.transition_state_to(battle.STATE_INFO, ["%s can't attack" % enemy.monster.character_name])
