extends PostAttackStrategy
class_name GigaDrainStrategy


func ApplyEffect(AttackResults: Monster.AttackResults) -> String:
	var damage = AttackResults.damage

	var half_damage = int(float(damage) / 2)

	var initial_hp = AttackResults.attacker.hp
	AttackResults.attacker.hp += half_damage
	var final_hp = AttackResults.attacker.hp

	var gained_hp = final_hp - initial_hp

	if gained_hp > 0:
		return "%s drained %d HP." % [AttackResults.attacker.character_name, gained_hp]
	else:
		return "%s's HP is full.\nGiga Drain did not drain any HP." % AttackResults.attacker.character_name
