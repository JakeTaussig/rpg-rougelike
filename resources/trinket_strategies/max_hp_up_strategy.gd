class_name MaxHpUpTrinketStrategy
extends TrinketStrategy


func ApplyEffect(monster: Monster):
	monster.max_hp += 100
	monster.hp += 100
