class_name Move extends Resource

enum MoveCategory {ATK, SP_ATK, EFFECT, STAT_MODIFIER}

var move_name = "Bubblebeam"

var type: MovesData.Type = MovesData.Type.Human

var category: MoveCategory = MoveCategory.ATK

# Accuracy
var acc: int = 100:
	set(new_acc):
		acc = max(0, new_acc)

var base_power: int = 50:
	set(new_base_power):
		base_power = max(1, new_base_power)

# Power Points
var pp: int = 10:
	set(new_pp):
		pp = max(0, new_pp)

# Max Power Points
var max_pp: int = 10:
	set(new_max_pp):
		max_pp = max(1, new_max_pp)

# 0 = Normal, 1 = Priority
var priority: bool = 0

func _init(_name: String, _type: MovesData.Type, _category:  MoveCategory, _acc: int, _bp: int, _pp: int, _priority: bool):
	move_name = _name
	type = _type
	category = category
	acc = _acc
	base_power = _bp
	pp = _pp
	max_pp = _pp
	priority = _priority

func copy() -> Move:
	return Move.new(move_name, type, category, acc, base_power, pp, priority)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _to_string() -> String:
	var output = ""
	for property_name in ["move_name", "type", "category", "acc", "base_power", "pp", "max_pp", "priority"]:
		output += "\n%s: %s" % [property_name, get(property_name)]
		
	return output

	
