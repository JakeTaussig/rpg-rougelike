extends BaseState

var statuses_enacted = false
var dead_monster = false

func enter(_messages: Array = []):
	if not dead_monster:
		var message = _check_for_dead_monsters()
		if message != "":
			battle.transition_state_to(battle.STATE_INFO, [message])
			return
	# Checks if the current selected_monster is dead and if the battle is over
	if battle.is_battle_over():
		battle.transition_state_to(battle.STATE_BATTLE_OVER)
		return

	# enact statuses before updating the turn order
	if battle.turn_order_index == battle.active_monsters.size() - 1 and not statuses_enacted:
		statuses_enacted = true
		battle.transition_state_to(battle.STATE_ENACT_STATUSES)
		return

	battle.turn_order_index = (battle.turn_order_index + 1) % battle.active_monsters.size()
	if battle.turn_order_index == 0 || dead_monster:
		dead_monster = false
		statuses_enacted = false
		battle.turn += 1
		battle.enemy.swap_dead_monster()
		battle.update_active_monsters()
		battle.render_hp()
		
	_log_turn_info()
	battle.ui_manager.set_turn_display("trn: %s idx: %s" % [battle.turn, battle.turn_order_index])

	if battle.active_monsters[battle.turn_order_index].is_player:
		battle.transition_state_to(battle.STATE_SELECTING_ACTION)
	else:
		battle.transition_state_to(battle.STATE_ENEMY_ATTACK)

func _check_for_dead_monsters() -> String:
	var message = ""

	for battler in battle.battle_participants:
		if battler.selected_monster.hp <= 0:
			message = "%s defeated %s!" % [GameManager.player.selected_monster.character_name, battler.selected_monster.character_name]
			dead_monster = true

	return message
		

func _log_turn_info():
	if (battle.turn_order_index == 0):
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
