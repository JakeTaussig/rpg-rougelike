extends Resource
class_name MovesList

var moves: Array[Move]

func _init():
	_initialize_moves()

func _initialize_moves():
	moves.append(Move.new("Tackle", Move.Types.Human, Move.MoveCategory.ATK, 90, 35, 30, false))
	moves.append(Move.new("Flamethrower", Move.Types.Fire, Move.MoveCategory.SP_ATK, 100, 100, 15, false))
	moves.append(Move.new("Bubblebeam", Move.Types.Water, Move.MoveCategory.SP_ATK, 100, 60, 20, false))
	moves.append(Move.new("Fire Punch", Move.Types.Fire, Move.MoveCategory.SP_ATK, 95, 75, 10, false))
