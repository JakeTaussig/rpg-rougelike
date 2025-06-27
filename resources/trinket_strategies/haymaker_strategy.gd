class_name HaymakerTrinketStrategy
extends TrinketStrategy
# All trinket effects are applied in order on battle start


func ApplyEffect(monster: Monster):
	monster.def = monster.def * 2
	monster.acc *= 0.5
