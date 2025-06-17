class_name Move extends Resource

enum MoveCategory {ATK, SP_ATK, STATUS_EFFECT, STAT_MODIFIER}
@export var move_name: String = "Bubblebeam"
@export var category: MoveCategory = MoveCategory.ATK
@export var type: MovesList.Type = MovesList.Type.HUMAN

@export var base_power: int = 50:
	set(new_base_power):
		base_power = max(1, new_base_power)

# Accuracy
@export var acc: int = 100:
	set(new_acc):
		acc = max(0, new_acc)

# Power Points
@export var pp: int = 10:
	set(new_pp):
		pp = max(0, new_pp)

# Max Power Points
@export var max_pp: int = 10:
	set(new_max_pp):
		max_pp = max(1, new_max_pp)

@export var status_effect: MovesList.StatusEffect = MovesList.StatusEffect.NONE
@export var status_effect_chance: int = 100

# 0 = Normal, 1 = Priority
@export var priority: bool = 0

@export var backdrop: ShaderMaterial

# returns an identical copy of the current move
func copy() -> Move:
	var new_move = Move.new()
	var properties = get_property_list()

	for property in properties:
		# Only copy custom, writable properties
		var is_custom_property = property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE
		var is_writable_property = property.usage & PROPERTY_USAGE_STORAGE
		if is_custom_property and is_writable_property:
			var property_name = property["name"]
			new_move.set(property_name, get(property_name))

	return new_move
	
func _to_string() -> String:
	var output = ""
	for property_name in ["move_name", "type", "category", "acc", "base_power", "pp", "max_pp", "priority"]:
		output += "\n%s: %s" % [property_name, get(property_name)]
		
	return output
