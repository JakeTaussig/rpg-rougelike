extends BaseState
var participants_statused: bool = false

func enter(messages: Array = []):
	var message = ""
	for participant in battle.battle_participants:
		if participant.status_effect != GameManager.moves_list.StatusEffect.NONE:
			match participant.status_effect_turn_counter:
				1: 
					message = participant.enact_status_effect()
					if message != "":
						messages.append(message)
				2: 
					message = participant.enact_status_effect()
					if message != "":
						messages.append(message)
				3: 
					if randi() % 4 == 0:
						message = participant.recover_from_status_effect()
					else:
						message = participant.enact_status_effect()
					if message != "":
						messages.append(message)
				4:
					if randi() % 3 == 0:
						message = participant.recover_from_status_effect()
					else:
						message = participant.enact_status_effect()
					if message != "":
						messages.append(message)
				5: 
					if randi() % 2 == 0:
						message = participant.recover_from_status_effect()
					else:
						message = participant.enact_status_effect()
					if message != "":
						messages.append(message)
				6:     
					message = participant.recover_from_status_effect()
					if message != "":
						messages.append(message)

	if messages.size() > 0:
		battle.transition_state_to(battle.STATE_INFO, messages)
	else:
		battle.transition_state_to(battle.STATE_INCREMENT_TURN)
