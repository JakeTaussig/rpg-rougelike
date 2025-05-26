extends Resource
class_name MovesList

@export var moves: Array[Move]

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
