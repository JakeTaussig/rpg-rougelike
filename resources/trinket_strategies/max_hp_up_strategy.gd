class_name MaxHpUpTrinketStrategy
extends TrinketStrategy

func ApplyEffect(monster: Monster):
	monster.max_hp += 100
	monster.hp += 100

func RemoveEffect(monster: Monster):
	monster.max_hp -= 100
	if monster.hp > monster.max_hp:
		monster.hp = monster.max_hp
