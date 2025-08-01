extends PreAttackStrategy
class_name PreVolcano


func ApplyEffect(AttackResults: Monster.AttackResults) -> String:
	var move = AttackResults.move
	var attacker = AttackResults.attacker
	move.base_power = int((150 * attacker.hp) / attacker.max_hp)
	return ""
