extends Resource
class_name MovesList

@export var moves: Array[Move]

enum Type {HUMAN, FIRE, WATER, PLANT, PLASMA, DARK, LIGHT}
				  		# HUMAN, FIRE,  WATER,   PLANT,   PLASMA,   DARK,   LIGHT
enum StatusEffect {NONE, CRIPPLE, BURN, WHIRLPOOL, POISON, PARALYZE, CONSUME, BLIND}


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


static func type_to_color(type: Type) -> Color:
	match type:
		Type.HUMAN:
			return Color(1.0, 0.0, 0.267, 1.0)
		Type.FIRE:
			return Color(0.894, 0.231, 0.267, 1.0)
		Type.WATER:
			return Color(0.0, 0.6, 0.859, 1.0)
		Type.PLANT:
			return Color(0.149, 0.361, 0.259, 1.0)
		Type.PLASMA:
			return Color(0.71, 0.314, 0.533, 1.0)
		Type.DARK:
			return Color(0.094, 0.078, 0.145, 1.0)
		Type.LIGHT:
			return Color(0.545, 0.608, 0.706, 1.0)

	return Color(0, 1.0, 0.0, 1.0)
