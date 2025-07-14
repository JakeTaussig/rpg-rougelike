extends BaseState


func enter(_messages: Array = []):
	var enemy = GameManager.enemy
	var enemyMoveIdx = enemy.select_move()
	if enemyMoveIdx != -1:
		var attackCommand = AttackState.AttackCommand.new()
		attackCommand.attacker = enemy.selected_monster
		attackCommand.move = GameManager.enemy.selected_monster.moves[enemyMoveIdx]
		attackCommand.target = GameManager.player.selected_monster
		battle.transition_state_to(battle.STATE_ATTACK, [attackCommand])
	else:
		battle.transition_state_to(battle.STATE_INFO, ["%s can't attack" % enemy.monster.character_name])
