extends BaseState

var statuses_enacted = false


func enter(_messages: Array = []):
	# Checks if the current selected_monster is dead and if the battle is over
	var is_battle_over = await _check_battle_status()
	if is_battle_over:
		return
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

	# TODO: This is why the await %ContinueButton.pressed is needed. because it doesn't return and gets sent to the state here.
	if battle.active_monsters[battle.turn_order_index].is_player:
		battle.transition_state_to(battle.STATE_SELECTING_ACTION)
	else:
		battle.transition_state_to(battle.STATE_ENEMY_ATTACK)


func _check_battle_status() -> bool:
	for battler in battle.battle_participants:
		if battler.is_defeated():
			await battle.transition_state_to(battle.STATE_BATTLE_OVER)
			return true
		# Unless the player ever has more than one monster, this will always be the enemy
		elif battler.selected_monster.hp <= 0:
			print(battler.selected_monster.hp)
			var index := battle.active_monsters.find(battler.selected_monster)
			var messages = ["%s defeated %s!" % [GameManager.player.selected_monster.character_name, battler.selected_monster.character_name]]
			battler.monsters.remove_at(0)
			await battle.transition_state_to(battle.STATE_INFO, messages)
			# I'm open to a fix for this, but otherwise the preceeding message doesn't show
			await %ContinueButton.pressed
			battler.selected_monster = battler.monsters[0]
			# TODO: potentially refactor so we only need the one is_player on battle_participant instead of both the monster and participant.
			battler.selected_monster.is_player = false
			battle.active_monsters[index] = battler.selected_monster
			%UiManager.render_hp(battle.battle_participants[0].selected_monster, battle.battle_participants[1].selected_monster)
			# Will flip over to 0
			battle.turn_order_index = 1
			battle.active_monsters.sort_custom(battle._sort_participants_by_speed)
	return false


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
