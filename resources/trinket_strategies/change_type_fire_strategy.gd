class_name ChangeTypeFireTrinketStrategy
extends TrinketStrategy
# All trinket effects are applied in order on battle start
func ApplyEffect(monster: Monster):
	monster.type = MovesList.Type.FIRE
