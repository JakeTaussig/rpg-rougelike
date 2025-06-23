class_name DmgUpTrinketStrategy
extends TrinketStrategy

func ApplyEffect(monster: Monster):
		monster.atk = int(float(monster.atk) * 1.20)
		monster.sp_atk = int(float(monster.sp_atk) * 1.20)

func RemoveEffect(monster: Monster):
	monster.atk = int(float(monster.atk) * (5.0/6.0))
	monster.sp_atk = int(float(monster.sp_atk) * (5.0/6.0))
