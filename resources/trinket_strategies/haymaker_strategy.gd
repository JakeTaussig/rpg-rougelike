class_name HaymakerTrinketStrategy
extends TrinketStrategy
# All trinket effects are applied in order on battle start

func ApplyEffect(monster: Monster):
	monster.def *= 2.0
	monster.acc *= 0.5

func RemoveEffect(monster: Monster):
	monster.def /= 2.0
	monster.acc *= 2.0
