class_name ChangeTypeFireTrinketStrategy
extends TrinketStrategy
# All trinket effects are applied in order on battle start
var original_type: MovesList.Type

func ApplyEffect(monster: Monster):
	original_type = monster.type
	monster.type = MovesList.Type.FIRE

func RemoveEffect(monster:Monster):
	monster.type = original_type
