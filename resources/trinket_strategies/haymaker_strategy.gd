class_name HaymakerTrinketStrategy
extends TrinketStrategy


func ApplyEffect(monster: Monster):
	monster.def = int(monster.def * 1.5)
	monster.acc *= 0.75
