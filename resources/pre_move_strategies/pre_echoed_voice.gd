extends PreAttackStrategy
class_name PreEchoedVoice


func ApplyEffect(AttackResults: Monster.AttackResults) -> String:
	var echoed_voice = AttackResults.move
	if not AttackResults.attacker.previous_move == echoed_voice or GameManager.current_battle.turn == 1:
		echoed_voice.base_power = 40
	return ""
