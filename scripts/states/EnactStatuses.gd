extends BaseState


func enter(messages: Array = []):
	var slow_monster = battle.active_monsters[1]
	var fast_monster = battle.active_monsters[0]
	var monster = slow_monster
	if messages:
		var slow_monster_processed: bool = messages[0]
		if slow_monster_processed:
			monster = fast_monster

	var output_messages = []
	if monster.status_effect != GameManager.moves_list.StatusEffect.NONE:
		var message = apply_status_effect(monster)
		if message != "":
			output_messages.append(message)

	battle.transition_state_to(battle.STATE_INFO, output_messages)


func apply_status_effect(monster):
	match monster.status_effect_turn_counter:
		0:
			monster.status_effect_turn_counter += 1
			var message = monster.enact_status_effect()
			if message != "":
				return message
		1:
			var message = monster.enact_status_effect()
			if message != "":
				return message
		2:
			var message = monster.enact_status_effect()
			if message != "":
				return message
		3:
			var message = ""
			if randi() % 4 == 0:
				message = monster.recover_from_status_effect()
			else:
				message = monster.enact_status_effect()
			if message != "":
				return message
		4:
			var message = ""
			if randi() % 3 == 0:
				message = monster.recover_from_status_effect()
			else:
				message = monster.enact_status_effect()
			if message != "":
				return message
		5:
			var message = ""
			if randi() % 2 == 0:
				message = monster.recover_from_status_effect()
			else:
				message = monster.enact_status_effect()
			if message != "":
				return message
		6:
			var message = monster.recover_from_status_effect()
			if message != "":
				return message
