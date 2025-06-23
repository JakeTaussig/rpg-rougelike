class_name ChangeTypeHumanTrinketStrategy
extends TrinketStrategy
# All trinket effects are applied in order on battle start
func ApplyEffect(monster: Monster):
	monster.type = MovesList.Type.HUMAN
