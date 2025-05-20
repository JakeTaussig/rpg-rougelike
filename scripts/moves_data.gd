extends Resource
class_name MovesData

var moves: Array[Move]

enum Type {Human, Fire, Water, Plant, Plasma, Dark, Light}

const TYPES = {
	Type.Human: 0,
	Type.Fire: 1,
	Type.Water: 2,
	Type.Plant: 3,
	Type.Plasma: 4,
	Type.Dark: 5,
	Type.Light: 6
}

const TYPE_CHART = [
# Human Fire  Water Grass Earth Dark  Light
[ 1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0 ], # Human
[ 1.0,  1.0,  0.5,  2.0,  1.0,  0.5,  2.0 ], # Fire
[ 1.0,  2.0,  1.0,  0.5,  2.0,  1.0,  0.5 ], # Water
[ 1.0,  0.5,  2.0,  1.0,  2.0,  0.5,  1.0 ], # Plant
[ 1.0,  1.0,  0.5,  0.5,  1.0,  2.0,  2.0 ], # Plasma
[ 1.0,  2.0,  1.0,  2.0,  0.5,  1.0,  0.5 ], # Dark
[ 1.0,  0.5,  2.0,  1.0,  0.5,  2.0,  1.0 ]  # Light
]

func _init():
	_initialize_moves()

func _initialize_moves():
	moves.append(Move.new("Tackle", Type.Human, Move.MoveCategory.ATK, 90, 35, 30, false))
	moves.append(Move.new("Flamethrower", Type.Fire, Move.MoveCategory.SP_ATK, 100, 100, 15, false))
	moves.append(Move.new("Bubblebeam", Type.Water, Move.MoveCategory.SP_ATK, 100, 60, 20, false))
	moves.append(Move.new("Fire Punch", Type.Fire, Move.MoveCategory.SP_ATK, 95, 75, 10, false))	
