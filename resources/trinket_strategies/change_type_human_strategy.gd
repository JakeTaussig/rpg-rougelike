class_name ChangeTypeHumanTrinketStrategy
extends TrinketStrategy

var original_type: MovesList.Type


func ApplyEffect(monster: Monster):
	original_type = monster.type
	monster.type = MovesList.Type.HUMAN
