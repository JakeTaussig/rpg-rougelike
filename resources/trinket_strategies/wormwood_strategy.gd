class_name WormwoodTrinketStrategy
extends TrinketStrategy


func ApplyEffect(monster: Monster):
	for move in monster.moves:
		if move.type == MovesList.Type.WATER:
			move.base_power = int(float(move.base_power) * 1.25)
