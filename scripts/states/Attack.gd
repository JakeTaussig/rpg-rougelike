class_name AttackState
extends BaseState

func enter(params: Array = []):
	if params.size() != 1 or not params[0] is AttackCommand:
		push_error("AttackState: Expected AttackCommand")
		battle.transition_state_to(battle.STATE_ATTACKING_INFO, ["Invalid attack command"])
		return

	var command = params[0] as AttackCommand

	var attacker: BattleParticipant = command.attacker
	var target: BattleParticipant = command.target
	var move_index: int = command.move_index

	# Execute attack
	var results = attacker.use_move(move_index, target)
	var used_move = attacker.moves[move_index]
	var messages = _generate_attack_messages(attacker, target, used_move, results)

	# Transition to AttackingInfoState to show results
	battle.transition_state_to(battle.STATE_ATTACKING_INFO, messages)

func _generate_attack_messages(attacker, target, used_move, results) -> Array:
	var messages = []
	var used_move_name = results["move"].move_name
	var damage = results["damage"]
	var move_hit = results["move_hit"]
	if not move_hit:
		messages.append("%s missed %s!" % [attacker.character_name, used_move_name])
	elif damage > 0:
		var effectiveness_multiplier: float = attacker.get_effectiveness_modifier(used_move, target)
		messages.append("%s used %s on %s for %d damage!" % [attacker.monster.character_name, used_move_name, target.monster.character_name, damage])

		if effectiveness_multiplier > 1.0:
			messages.append("%s was super effective!" % used_move_name)

		elif effectiveness_multiplier < 1.0:
			messages.append("%s was not very effective!" % used_move_name)

	# This should only be status effects for now
	else:
		var status_effect_string = String(MovesList.StatusEffect.find_key(target.status_effect)).to_lower()
		messages.append("%s used %s and applied %s on %s!" % [attacker.monster.character_name, used_move_name, status_effect_string, target.monster.character_name])
	return messages

# Inner class. Used to pass data to `AttackState.enter`
class AttackCommand:
	var attacker: BattleParticipant
	var target: BattleParticipant
	var move_index: int
