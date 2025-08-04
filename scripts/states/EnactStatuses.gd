extends BaseState
var participants_statused: bool = false


func enter(messages: Array = []):
	var message = ""
	for monster in battle.active_monsters:
		if monster.status_effect != GameManager.moves_list.StatusEffect.NONE:
			match monster.status_effect_turn_counter:
				0:
					message = monster.enact_status_effect()
					if message != "":
						messages.append(message)
				1:
					message = monster.enact_status_effect()
					if message != "":
						messages.append(message)
				2:
					if randi() % 4 == 0:
						message = monster.recover_from_status_effect()
					else:
						message = monster.enact_status_effect()
					if message != "":
						messages.append(message)
				3:
					if randi() % 3 == 0:
						message = monster.recover_from_status_effect()
					else:
						message = monster.enact_status_effect()
					if message != "":
						messages.append(message)
				4:
					if randi() % 2 == 0:
						message = monster.recover_from_status_effect()
					else:
						message = monster.enact_status_effect()
					if message != "":
						messages.append(message)
				5:
					message = monster.recover_from_status_effect()
					if message != "":
						messages.append(message)

	battle.transition_state_to(battle.STATE_INFO, messages)
