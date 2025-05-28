extends BaseState

func enter(messages: Array = []):
	var enemy = battle.get_current_attacker()
	var enemyMoveIdx = enemy.select_move()
	if enemyMoveIdx != -1:
		battle.transition_state_to(
			battle.STATE_ATTACK,
			[{
				"attacker": enemy,
				"move_index": enemyMoveIdx,
				"target": %Player
			}])
	else:
		battle.transition_state_to(battle.STATE_ATTACKING_INFO, ["%s can't attack" % enemy.character_name])
