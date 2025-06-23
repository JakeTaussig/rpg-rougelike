class_name ChangeTypeHumanTrinketStrategy
extends TrinketStrategy
# All trinket effects are applied in order on battle start
var original_type: MovesList.Type

func ApplyEffect(monster: Monster):
	original_type = monster.type
	monster.type = MovesList.Type.HUMAN

func RemoveEffect(monster: Monster):
	monster.type = original_type
