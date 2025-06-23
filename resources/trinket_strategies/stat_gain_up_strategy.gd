class_name StatGainUpTrinketStrategy
extends TrinketStrategy

func ApplyEffect(monster: Monster):
	GameManager.player_stat_multiplier += 0.1
func RemoveEffect(monster: Monster):
	GameManager.player_stat_multiplier -= 0.1
