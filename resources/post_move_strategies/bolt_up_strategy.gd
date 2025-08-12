extends PostAttackStrategy
class_name BoltUpStrategy


func ApplyEffect(AttackResults: Monster.AttackResults) -> String:
	var attacker: Monster = AttackResults.attacker

	var damage_to_take = int(AttackResults.damage * 0.33)

	attacker.hp -= damage_to_take

	return "%s took %d damage from recoil!" % [attacker.character_name, damage_to_take]
