extends PostAttackStrategy
class_name SpecialBeamStrategy


func ApplyEffect(AttackResults: Monster.AttackResults) -> String:
	var attacker: Monster = AttackResults.attacker

	var initial_sp_attack = attacker.sp_atk

	attacker.sp_atk = int(float(attacker.sp_atk) * 0.5)

	var final_sp_attack = attacker.sp_atk

	return "%s's special attack fell from %d to %d" % [attacker.character_name, initial_sp_attack, final_sp_attack]
