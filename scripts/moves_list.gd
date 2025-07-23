extends Resource
class_name MovesList

@export var moves: Array[Move]

enum Type { EARTH, WATER, FIRE, AIR, ETHER, LIGHT, COSMIC }

# Some status effects will need to be re-done to correspond to the appropriate chakra types.
enum StatusEffect { NONE, CRIPPLE, DELUSION, BURN, POISON, PARALYZE, BLIND, CONSUME }

const TYPES = {Type.EARTH: 0, Type.WATER: 1, Type.FIRE: 2, Type.AIR: 3, Type.ETHER: 4, Type.LIGHT: 5, Type.COSMIC: 6}  # Root Chakra/Muladhara  # Sacral Chakra/Svadhisthana  # Solar Plexus/Manipura  # Heart Charka/Anahata  # Throat Charka/Vishuddha  # Third Eye/Ajna  # Crown Chakra/Sahasrara


static func type_to_color(type: Type) -> Color:
	match type:
		Type.EARTH:
			return Color(0.91, 0.718, 0.588, 1.0)
		Type.WATER:
			return Color(0.0, 0.6, 0.859, 1.0)
		Type.FIRE:
			return Color(0.894, 0.231, 0.267, 1.0)
		Type.AIR:
			return Color(0.173, 0.91, 0.961, 1.0)
		Type.ETHER:
			return Color(0.71, 0.314, 0.533, 1.0)
		Type.LIGHT:
			return Color(0.545, 0.608, 0.706, 1.0)
		Type.COSMIC:
			return Color(0.996, 0.906, 0.38, 1.0)

	return Color(1.0, 1.0, 1.0, 0.0)


static func status_effect_to_color(status_effect: StatusEffect) -> Color:
	match status_effect:
		MovesList.StatusEffect.CRIPPLE:
			return Color(0.91, 0.718, 0.588, 1.0)
		MovesList.StatusEffect.BURN:
			return Color(0.894, 0.231, 0.267, 1.0)
		MovesList.StatusEffect.DELUSION:
			return Color(0.0, 0.6, 0.859, 1.0)
		MovesList.StatusEffect.POISON:
			return Color(0.173, 0.91, 0.961, 1.0)
		MovesList.StatusEffect.PARALYZE:
			return Color(0.71, 0.314, 0.533, 1.0)
		MovesList.StatusEffect.BLIND:
			return Color(0.545, 0.608, 0.706, 1.0)
		MovesList.StatusEffect.CONSUME:
			return Color(0.996, 0.906, 0.38, 1.0)

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
		MovesList.StatusEffect.BLIND:
			return "BLD"
		MovesList.StatusEffect.CONSUME:
			return "CSM"
	printerr("Failed to match type abbreviation")
	return ""
