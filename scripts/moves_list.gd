extends Resource
class_name MovesList

@export var moves: Array[Move]

enum Type { EARTH, WATER, FIRE, AIR, ETHER, LIGHT, COSMIC }

# Some status effects will need to be re-done to correspond to the appropriate
# chakra types.
#
# CRIPPLE is deprecated. If we remove it, we'll need to update
# every move resource, so I'm going to leave it in the enum for now.
enum StatusEffect { NONE, CRIPPLE, WHIRLPOOL, BURN, POISON, FREEZE, BLIND, VACUUM }

const TYPES = {Type.EARTH: 0, # Root Chakra/Muladhara
			   Type.WATER: 1, # Sacral Chakra/Svadhisthana
			   Type.FIRE: 2, # Solar Plexus/Manipura
			   Type.AIR: 3, # Heart Charka/Anahata
			   Type.ETHER: 4, # Throat Charka/Vishuddha
			   Type.LIGHT: 5, # Third Eye/Ajna 
			   Type.COSMIC: 6} # Crown Chakra/Sahasrara          


static func type_to_color(type: Type) -> Color:
	match type:
		Type.EARTH:
			return Color(0.388, 0.78, 0.302, 1.0)
		Type.WATER:
			return Color(0.0, 0.6, 0.859, 1.0)
		Type.FIRE:
			return Color(0.894, 0.231, 0.267, 1.0)
		Type.AIR:
			return Color(0.753, 0.796, 0.863, 1.0)
		Type.ETHER:
			return Color(0.227, 0.267, 0.4, 1.0)
		Type.LIGHT:
			return Color(0.918, 0.831, 0.667, 1.0)
		Type.COSMIC:
			return Color(0.71, 0.314, 0.533, 1.0)

	return Color(1.0, 1.0, 1.0, 0.0)


static func status_effect_to_color(status_effect: StatusEffect) -> Color:
	match status_effect:
		MovesList.StatusEffect.POISON:
			return Color(0.388, 0.78, 0.302, 1.0)
		MovesList.StatusEffect.WHIRLPOOL:
			return Color(0.0, 0.6, 0.859, 1.0)
		MovesList.StatusEffect.BURN:
			return Color(0.894, 0.231, 0.267, 1.0)
		MovesList.StatusEffect.FREEZE:
			return Color(0.545, 0.608, 0.706, 1.0)
		MovesList.StatusEffect.VACUUM:
			return Color(0.227, 0.267, 0.4, 1.0)
		MovesList.StatusEffect.BLIND:
			return Color(0.918, 0.831, 0.667, 1.0)

	return Color(1.0, 1.0, 1.0, 0.0)


static func type_abbreviation(effect) -> String:
	match effect:
		MovesList.StatusEffect.BURN:
			return "BRN"
		MovesList.StatusEffect.WHIRLPOOL:
			return "WRL"
		MovesList.StatusEffect.POISON:
			return "PSN"
		MovesList.StatusEffect.FREEZE:
			return "FRZ"
		MovesList.StatusEffect.BLIND:
			return "BLD"
		MovesList.StatusEffect.VACUUM:
			return "VAC"
	printerr("Failed to match type abbreviation")
	return ""
