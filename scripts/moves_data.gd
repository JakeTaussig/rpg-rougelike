extends Resource
class_name MovesData

var moves: Array[Move]

enum Type {HUMAN, FIRE, WATER, PLANT, PLASMA, DARK, LIGHT}
				  		# HUMAN, FIRE, WATER,    PLANT,   DARK,   LIGHT
enum StatusEffect {NONE, BLEED, BURN, WHIRLPOOL, POISON, CONSUME, BLIND}

const TYPES = {
	Type.HUMAN: 0,
	Type.FIRE: 1,
	Type.WATER: 2,
	Type.PLANT: 3,
	Type.PLASMA: 4,
	Type.DARK: 5,
	Type.LIGHT: 6
}

# Row = Attacker, Col = Defender
const TYPE_CHART = [
# HUMAN FIRE  WATER PLANT Earth DARK  LIGHT
[ 1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0 ], # HUMAN
[ 1.0,  1.0,  0.5,  2.0,  1.0,  0.5,  2.0 ], # FIRE
[ 1.0,  2.0,  1.0,  0.5,  2.0,  1.0,  0.5 ], # WATER
[ 1.0,  0.5,  2.0,  1.0,  2.0,  0.5,  1.0 ], # PLANT
[ 1.0,  1.0,  0.5,  0.5,  1.0,  2.0,  2.0 ], # PLASMA
[ 1.0,  2.0,  1.0,  2.0,  0.5,  1.0,  0.5 ], # DARK
[ 1.0,  0.5,  2.0,  1.0,  0.5,  2.0,  1.0 ]  # LIGHT
]

func _init():
	_initialize_moves()

func _initialize_moves():
	# name, type, category, accuracy, base_power, power_points, priority, status_effect, status_effect_chance
	moves.append(Move.new("Tackle", Type.HUMAN, Move.MoveCategory.ATK, 90, 35, 30, false))
	moves.append(Move.new("Flamethrower", Type.FIRE, Move.MoveCategory.SP_ATK, 100, 100, 15, false))
	moves.append(Move.new("Bubblebeam", Type.WATER, Move.MoveCategory.SP_ATK, 100, 60, 20, false))
	moves.append(Move.new("Heat Wave", Type.FIRE, Move.MoveCategory.STATUS_EFFECT, 75, 0, 10, false, StatusEffect.BURN, 100))
	#moves.append(Move.new("Fire Punch", Type.FIRE, Move.MoveCategory.SP_ATK, 95, 75, 10, false))
