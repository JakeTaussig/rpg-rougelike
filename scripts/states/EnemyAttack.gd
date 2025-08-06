extends BaseState


func enter(_messages: Array = []):
	var enemy = GameManager.enemy
	var enemyMoveIdx = enemy.select_move()
	if enemyMoveIdx != -1:
		var attackCommand = AttackState.AttackCommand.new()
		attackCommand.attacker = enemy.selected_monster
		attackCommand.move = GameManager.enemy.selected_monster.moves[enemyMoveIdx]
		attackCommand.target = GameManager.player.selected_monster
		battle.enemy_attack = attackCommand

	# keep the game loop going even if there isn't a valid move
	battle.transition_state_to(battle.STATE_INCREMENT_TURN)
