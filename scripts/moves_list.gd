extends Resource
class_name MovesList

@export var moves: Array[Move]

enum Type {HUMAN, FIRE, SPIRIT, POISON, PLASMA, DARK, LIGHT}
				  		# HUMAN, FIRE,  SPIRIT,   POISON,   PLASMA,   DARK,   LIGHT
enum StatusEffect {NONE, CRIPPLE, BURN, DELUSION, POISON, PARALYZE, CONSUME, BLIND}


const TYPES = {
	Type.HUMAN: 0,
	Type.FIRE: 1,
	Type.SPIRIT: 2,
	Type.POISON: 3,
	Type.PLASMA: 4,
	Type.DARK: 5,
	Type.LIGHT: 6
}

# Row = Attacker, Col = Defender
const TYPE_CHART = [
# HUMAN FIRE  SPIRIT POISON Earth DARK  LIGHT
[ 1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0 ], # HUMAN
[ 1.0,  1.0,  0.5,  2.0,  1.0,  0.5,  2.0 ], # FIRE
[ 1.0,  2.0,  1.0,  0.5,  2.0,  1.0,  0.5 ], # SPIRIT
[ 1.0,  0.5,  2.0,  1.0,  2.0,  0.5,  1.0 ], # POISON
[ 1.0,  1.0,  0.5,  0.5,  1.0,  2.0,  2.0 ], # PLASMA
[ 1.0,  2.0,  1.0,  2.0,  0.5,  1.0,  0.5 ], # DARK
[ 1.0,  0.5,  2.0,  1.0,  0.5,  2.0,  1.0 ]  # LIGHT
]


static func type_to_color(type: Type) -> Color:
	match type:
		Type.HUMAN:
			return Color(0.996, 0.906, 0.38, 1.0)
		Type.FIRE:
			return Color(0.894, 0.231, 0.267, 1.0)
		Type.SPIRIT:
			return Color(0.0, 0.6, 0.859, 1.0)
		Type.POISON:
			return Color(0.388, 0.78, 0.302, 1.0)
		Type.PLASMA:
			return Color(0.71, 0.314, 0.533, 1.0)
		Type.DARK:
			return Color(0.227, 0.267, 0.4, 1.0)
		Type.LIGHT:
			return Color(0.545, 0.608, 0.706, 1.0)

	return Color(1.0, 1.0, 1.0, 0.0)

static func status_effect_to_color(status_effect: StatusEffect) -> Color:
	match status_effect:
		MovesList.StatusEffect.CRIPPLE:
			return Color(0.996, 0.906, 0.38, 1.0)
		MovesList.StatusEffect.BURN:
			return Color(0.894, 0.231, 0.267, 1.0)
		MovesList.StatusEffect.DELUSION:
			return Color(0.0, 0.6, 0.859, 1.0)
		MovesList.StatusEffect.POISON:
			return Color(0.388, 0.78, 0.302, 1.0)
		MovesList.StatusEffect.PARALYZE:
			return Color(0.71, 0.314, 0.533, 1.0)
		MovesList.StatusEffect.CONSUME:
			return Color(0.227, 0.267, 0.4, 1.0)
		MovesList.StatusEffect.BLIND:
			return Color(0.545, 0.608, 0.706, 1.0)

	return Color(1.0, 1.0, 1.0, 0.0)

static func type_abbreviation(effect) -> String:
	match effect:
		MovesList.StatusEffect.CRIPPLE:
			return "CRP"
		MovesList.StatusEffect.BURN:
			return "BRN"
		MovesList.StatusEffect.DELUSION:
			return "DEL"
		MovesList.StatusEffect.POISON:
			return "PSN"
		MovesList.StatusEffect.PARALYZE:
			return "PAR"
		MovesList.StatusEffect.CONSUME:
			return "CSM"
		MovesList.StatusEffect.BLIND:
			return "BLD"
	printerr("Failed to match type abbreviation")
	return ""
