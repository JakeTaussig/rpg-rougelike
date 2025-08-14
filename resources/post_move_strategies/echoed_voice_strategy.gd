extends PostAttackStrategy
class_name EchoedVoiceStrategy


func ApplyEffect(AttackResults: Monster.AttackResults) -> String:
	var echoed_voice = AttackResults.move

	var initial_power = echoed_voice.base_power
	echoed_voice.base_power += 20
	var final_power = echoed_voice.base_power

	return "the power of Echoed Voice increased from %d to %d" % [initial_power, final_power]
