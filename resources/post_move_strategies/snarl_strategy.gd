extends PostAttackStrategy
class_name SnarlStrategy


func ApplyEffect(AttackResults: Monster.AttackResults) -> String:
	var target: Monster = AttackResults.target

	var initial_sp_attack = target.sp_atk

	target.sp_atk = int(float(target.sp_atk) * 0.9)

	var final_sp_attack = target.sp_atk

	# TODO: this message appears even if the enemy is killed by the attack
	return "%s's special attack fell from %d to %d" % [target.character_name, initial_sp_attack, final_sp_attack]
