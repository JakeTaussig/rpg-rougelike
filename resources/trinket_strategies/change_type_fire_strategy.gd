class_name ChangeTypeFireTrinketStrategy
extends TrinketStrategy

var original_type: MovesList.Type


func ApplyEffect(monster: Monster):
	original_type = monster.type
	monster.type = MovesList.Type.FIRE
