extends BaseState

var statuses_enacted = false

func enter(_messages: Array = []):
	# Checks if the current selected_monster is dead and if the battle is over
	_check_battle_status()
	# enact statuses before updating the turn order
	if battle.turn_order_index == battle.active_monsters.size() - 1 and not statuses_enacted:
		statuses_enacted = true
		battle.transition_state_to(battle.STATE_ENACT_STATUSES)
		return

	battle.turn_order_index = (battle.turn_order_index + 1) % battle.active_monsters.size()
	if battle.turn_order_index == 0:
		statuses_enacted = false
		battle.turn += 1

	_log_turn_info()

	battle.ui_manager.set_turn_display("trn: %s idx: %s" % [battle.turn, battle.turn_order_index])

	if battle.active_monsters[battle.turn_order_index].is_player:
		battle.transition_state_to(battle.STATE_SELECTING_ACTION)
	else:
		battle.transition_state_to(battle.STATE_ENEMY_ATTACK)
		
func _check_battle_status() -> void:
	for battler in battle.battle_participants:
		if battler.is_defeated():
			#TODO: either change GAME_END to BATTLE_OVER state, or do something else to transition to next battle if the player wins here.
			battle.transition_state_to(battle.STATE_GAME_END)
		elif battler.selected_monster.hp <= 0:
			var index := battle.active_monsters.find(battler.selected_monster)
			battler.monsters.remove_at(0)
			battler.selected_monster = battler.monsters[0]
			battle.active_monsters[index] = battler.selected_monster

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
