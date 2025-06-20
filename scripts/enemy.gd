@tool
class_name Enemy extends BattleParticipant

enum AI_TYPE { RANDOM, AGGRESSIVE, HIGH_EV }
@export var ai_type: AI_TYPE = AI_TYPE.HIGH_EV
var ai_types = AI_TYPE.values()


func setup_enemy(_monsters: Array[Monster], _ai_type_index: int, stat_multiplier: float):
	monsters = _monsters
	for monster in monsters:
		monster.is_player = false
		monster.max_hp *= stat_multiplier
		monster.hp *= stat_multiplier
		monster.atk *= stat_multiplier
		monster.sp_atk *= stat_multiplier
		monster.def *= stat_multiplier
		monster.sp_def *= stat_multiplier
		monster.speed *= stat_multiplier
		monster.luck *= stat_multiplier
	ai_type = ai_types[_ai_type_index]
	position = Vector2(192, 40)


func _ready():
	is_player = false


func select_move() -> int:
	var available_moves = []
	for i in selected_monster.moves.size():
		if selected_monster.moves[i].pp > 0:
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
				if selected_monster.moves[idx].base_power > max_power:
					max_power = selected_monster.moves[idx].base_power
					best_move = idx
			return best_move
		AI_TYPE.HIGH_EV:
			var best_move = available_moves[0]
			var max_ev = 0
			for idx in available_moves:
				var move = selected_monster.moves[idx]
				var move_ev = move.base_power * move.acc
				if move_ev > max_ev:
					max_ev = move_ev
					best_move = idx
			return best_move
	return available_moves.pick_random()
