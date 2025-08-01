class_name GlassCannonTrinketStrategy
extends TrinketStrategy


func ApplyEffect(monster: Monster):
	monster.atk = int(monster.atk * 1.5)
	monster.sp_atk = int(monster.atk * 1.5)
	monster.def = int(monster.def / 1.5)
	monster.sp_def = int(monster.sp_def / 1.5)
