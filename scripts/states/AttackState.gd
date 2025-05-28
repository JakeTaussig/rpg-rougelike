class_name AttackState
extends BaseState

var attacker: BattleParticipant
var target: BattleParticipant
var move_index: int

func enter(params: Array = []):
	# params[0] should be a dictionary in the form:
	# {
	#  "attacker": %Player,
	#  "move_index": index,
	#  "target": battle.enemy
	# }
	var attack_params = params[0] as Dictionary
	attacker = attack_params.attacker
	move_index = attack_params.move_index
	target = attack_params.target

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
		messages.append("%s used %s on %s for %d damage!" % [attacker.character_name, used_move_name, target.character_name, damage])

		if effectiveness_multiplier > 1.0:
			messages.append("%s was super effective!" % used_move_name)

		elif effectiveness_multiplier < 1.0:
			messages.append("%s was not very effective!" % used_move_name)

	# This should only be status effects for now
	else:
		var status_effect_string = String(MovesList.StatusEffect.find_key(target.status_effect)).to_lower()
		messages.append("%s used %s and applied %s on %s!" % [attacker.character_name, used_move_name, status_effect_string, target.character_name])
	return messages
