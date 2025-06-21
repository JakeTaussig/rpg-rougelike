class_name AttackState
extends BaseState


func enter(params: Array = []):
	if params.size() != 1 or not params[0] is AttackCommand:
		push_error("AttackState: Expected AttackCommand")
		battle.transition_state_to(battle.STATE_INFO, ["Invalid attack command"])
		return

	var command = params[0] as AttackCommand

	var attacker: Monster = command.attacker
	var target: Monster = command.target
	var move_index: int = command.move_index

	# Execute attack
	var results: Monster.AttackResults = attacker.use_move(move_index, target)
	var messages = _generate_attack_messages(attacker, target, results)

	if results.move.backdrop:
		battle.ui_manager.set_backdrop_material(results.move.backdrop)

	# Transition to AttackingInfoState to show results
	battle.transition_state_to(battle.STATE_INFO, messages)


func _generate_attack_messages(attacker, target, results) -> Array:
	var messages = []
	var used_move = results.move
	var used_move_name = used_move.move_name
	var damage = results.damage
	var move_hit = results.move_hit
	var is_critical = results.is_critical
	if used_move_name == "Whirlpool":
		messages.append("%s got caught in the whirlpool and took %d damage!" % [attacker.character_name, damage])
		return messages
	elif used_move_name == "Paralyzed":
		messages.append("%s is paralyzed and could not move!" % attacker.character_name)
	elif not move_hit:
		messages.append("%s missed %s!" % [attacker.character_name, used_move_name])
	elif damage > 0:
		var effectiveness_multiplier: float = attacker.get_effectiveness_modifier(used_move, target)
		var message = "%s used %s on %s for %d damage!" % [attacker.character_name, used_move_name, target.character_name, min(damage, target.prior_hp)]
		if is_critical:
			message += " Critical Hit!"
		messages.append(message)

		if effectiveness_multiplier > 1.0:
			messages.append("%s was super effective!" % used_move_name)

		elif effectiveness_multiplier < 1.0:
			messages.append("%s was not very effective!" % used_move_name)

		# if the damage killed someone we don't need to see any more messages (We might need to to send out the enemies next monster
		if battle.is_battle_over():
			return messages
	# This condition only triggers when a status effect only move hit, but a status effect is already applied to the target. Or when a target is immune to the status effect.
	elif not results.status_applied:
		var target_status_effect_string = String(MovesList.StatusEffect.find_key(target.status_effect)).to_lower()
		var attempted_status_effect_string = String(MovesList.StatusEffect.find_key(used_move.status_effect)).to_lower()
		if target.status_effect == MovesList.StatusEffect.NONE:
			messages.append(
				(
					"%s used %s and attempted to apply %s on %s, but %s is immune!"
					% [attacker.character_name, used_move_name, attempted_status_effect_string, target.character_name, target.character_name]
				)
			)
		else:
			messages.append(
				(
					"%s used %s and attempted to apply %s on %s, but %s is already afflicted with %s!"
					% [attacker.character_name, used_move_name, attempted_status_effect_string, target.character_name, target.character_name, target_status_effect_string]
				)
			)

	if not target.is_alive:
		return messages

	if results.status_applied:
		var status_effect = target.status_effect
		# Different message if the move only applies status effect or if it also did damage. In this case we need to display the move name.
		var status_effect_string = String(MovesList.StatusEffect.find_key(status_effect)).to_lower()
		if used_move.category == Move.MoveCategory.STATUS_EFFECT:
			messages.append("%s used %s and applied %s on %s!" % [attacker.character_name, used_move_name, status_effect_string, target.character_name])
		else:
			messages.append("%s was afflicted with %s!" % [target.character_name, status_effect_string])
		# Burn and cripple need to be applied instantly since they affect the stats of the afflicted user.
		match status_effect:
			MovesList.StatusEffect.CRIPPLE:
				messages.append(target.enact_cripple_on_self())
			MovesList.StatusEffect.BURN:
				messages.append(target.enact_burn_on_self())
			MovesList.StatusEffect.BLIND:
				messages.append("%s's accuracy was lowered by 33" % target.character_name + "%!")
	return messages


# Inner class. Used to pass data to `AttackState.enter`
class AttackCommand:
	var attacker: Monster
	var target: Monster
	var move_index: int
