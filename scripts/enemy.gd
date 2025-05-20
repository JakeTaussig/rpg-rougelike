class_name Enemy extends BattleParticipant

enum AI_TYPE { RANDOM, AGGRESSIVE, HIGH_EV }
@export var ai_type: AI_TYPE = AI_TYPE.HIGH_EV

# Only called by enemy
func select_move() -> int:
	var available_moves = []
	for i in moves.size():
		if moves[i].pp > 0:
			available_moves.append(i)
	if available_moves.is_empty():
		return -1

	match ai_type:
		AI_TYPE.RANDOM:
			return available_moves.pick_random()
		AI_TYPE.AGGRESSIVE:
			var best_move = available_moves[0]
			var max_power = 0
			for idx in available_moves:
				if moves[idx].base_power > max_power:
					max_power = moves[idx].base_power
					best_move = idx
			return best_move
		AI_TYPE.HIGH_EV:
			var best_move = available_moves[0]
			var max_ev = 0
			for idx in available_moves:
				var move = moves[idx]
				var move_ev = move.base_power * move.acc
				if move_ev > max_ev:
					max_ev = move_ev
					best_move = idx
			return best_move
	return available_moves.pick_random()
