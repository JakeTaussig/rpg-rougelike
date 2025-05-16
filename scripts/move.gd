class_name Move extends Resource

enum Types {Human, Fire, Water, Plant, Plasma, Dark, Light}

enum MoveCategory {ATK, SP_ATK, EFFECT, STAT_MODIFIER}

var move_name = "Bubblebeam"

var type: Types = Types.Human

var modifier: MoveCategory = MoveCategory.ATK

# Accuracy
var acc: int = 100

var base_power: int = 50

# Power Points
var pp: int = 10

# Max Power Points
var max_pp: int = 10

# 0 = Normal, 1 = Priority
var priority: bool = 0

func _init(_name: String, _type: Types, _modifier:  MoveCategory, _acc: int, _bp: int, _pp: int, _priority: bool):
	move_name = _name
	type = _type
	modifier = modifier
	acc = _acc
	base_power = _bp
	pp = _pp
	max_pp = _pp
	priority = _priority

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _to_string() -> String:
	var output = ""
	for property_name in ["move_name", "type", "modifier", "acc", "base_power", "pp", "max_pp", "priority"]:
		output += "\n%s: %s" % [property_name, get(property_name)]
		
	return output

	
