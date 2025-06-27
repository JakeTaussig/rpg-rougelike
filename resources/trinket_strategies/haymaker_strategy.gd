class_name HaymakerTrinketStrategy
extends TrinketStrategy


func ApplyEffect(monster: Monster):
	monster.def = monster.def * 2
	monster.acc *= 0.5
