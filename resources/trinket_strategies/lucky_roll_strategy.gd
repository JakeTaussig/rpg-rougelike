class_name LuckyRollTrinketStrategy
extends TrinketStrategy
# All trinket effects are applied in order on battle start

func ApplyEffect(monster: Monster):
	monster.crit_checks += 1

func RemoveEffect(monster: Monster):
	monster.crit_checks -= 1
