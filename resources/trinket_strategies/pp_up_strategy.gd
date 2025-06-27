class_name PPUpTrinketStrategy
extends TrinketStrategy


func ApplyEffect(monster: Monster):
	for move in monster.moves:
		move.max_pp = int(1.25 * move.max_pp)
		move.pp = move.max_pp
