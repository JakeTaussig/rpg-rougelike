extends BaseState

var statuses_enacted = false
var dead_monster = false
var attacks_executed = 0

func enter(_messages: Array = []):
	# check for dead monsters
	if not dead_monster:
		var message = _check_for_dead_monsters()
		if message != "":
			dead_monster = true
			battle.transition_state_to(battle.STATE_INFO, [message])
			return
	# Checks if the current selected_monster is dead and if the battle is over
	if battle.is_battle_over():
		battle.transition_state_to(battle.STATE_BATTLE_OVER)
		return

	# Execute attacks before updating the turn order
	if battle.turn_order_index == battle.active_monsters.size() - 1 and attacks_executed < battle.active_monsters.size():
		attacks_executed += 1
		if battle.active_monsters[attacks_executed - 1] == battle.player.selected_monster:
			battle.transition_state_to(battle.STATE_ATTACK, [battle.player_attack])
		else:
			# if the enemy is alive, process its attack. otherwise, return to
			# the start of the IncrementTurn workflow
			if battle.enemy.selected_monster.hp > 0:
				battle.transition_state_to(battle.STATE_ATTACK, [battle.enemy_attack])
			else:
				battle.transition_state_to(battle.STATE_INCREMENT_TURN)

		return

	# enact statuses before updating the turn order
	if battle.turn_order_index == battle.active_monsters.size() - 1 and not statuses_enacted:
		statuses_enacted = true
		battle.transition_state_to(battle.STATE_ENACT_STATUSES)
		return

	battle.turn_order_index = (battle.turn_order_index + 1) % battle.active_monsters.size()
	if battle.turn_order_index == 0 || dead_monster:
		attacks_executed = 0
		statuses_enacted = false
		battle.turn += 1
		if dead_monster:
			battle.turn_order_index = 0
			_swap_dead_monsters()
			dead_monster = false
		battle.update_active_monsters()

	_log_turn_info()
	if battle.battle_participants[battle.turn_order_index].is_player:
		battle.transition_state_to(battle.STATE_SELECTING_ACTION)
	else:
		battle.transition_state_to(battle.STATE_ENEMY_ATTACK)


func _check_for_dead_monsters() -> String:
	var player = GameManager.player
	var enemy = GameManager.enemy
	var message = ""
	if enemy.selected_monster.hp <= 0 and player.selected_monster.hp <= 0:
		message = "%s and %s wiped each other out!" % [enemy.selected_monster.character_name, player.selected_monster.character_name]
	elif enemy.selected_monster.hp <= 0:
		message = "%s defeated %s!" % [player.selected_monster.character_name, enemy.selected_monster.character_name]
	elif player.selected_monster.hp <= 0:
		message = "%s defeated %s!" % [enemy.selected_monster.character_name, player.selected_monster.character_name]

	return message


func _swap_dead_monsters():
	var player = GameManager.player
	var enemy = GameManager.enemy
	if enemy.selected_monster.hp <= 0:
		enemy.swap_dead_monster()
	if player.selected_monster.hp <= 0:
		player.swap_dead_monster()


func _log_turn_info():
	if battle.turn_order_index == 0:
		print("\t---------------------------")
		print("\tTurn: %d" % battle.turn)
		print("\t---------------------------")

	var attacker = battle.get_attacker()
	print("\tstarting\t\t%s's turn " % attacker.character_name)

	# log HP
	var first_player = battle.active_monsters[0]
	var second_player = battle.active_monsters[1]
	print("\t\t\t\t\tHP:")
	print("\t\t\t\t\t\t%s\t%d / %d" % [first_player.character_name, first_player.hp, first_player.max_hp])
	print("\t\t\t\t\t\t%s\t%d / %d" % [second_player.character_name, second_player.hp, second_player.max_hp])
