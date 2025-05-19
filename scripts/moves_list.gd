extends Resource
class_name MovesList

const moves: Array[Dictionary] = [
	{"name": "Tackle", "type": Move.Types.Human, "category": Move.MoveCategory.ATK, "acc": 90, "bp": 35, "pp": 30, "priority": 0},
	{"name": "Flamethrower", "type": Move.Types.Fire, "category": Move.MoveCategory.SP_ATK, "acc": 100, "bp": 100, "pp": 15, "priority": 0},
	{"name": "Bubblebeam", "type": Move.Types.Water, "category": Move.MoveCategory.SP_ATK, "acc": 100, "bp": 60, "pp": 20, "priority": 0},
	{"name": "Fire Punch", "type": Move.Types.Fire, "category": Move.MoveCategory.SP_ATK, "acc": 95, "bp": 75, "pp": 10, "priority": 0}
	]

var moves_list: Array[Move] = []

func initialize_moves():
	for move_object in moves:
		var move = Move.new(move_object["name"], move_object["type"], move_object["category"], move_object["acc"], move_object["bp"], move_object["pp"], move_object["priority"])
		moves_list.append(move)

func _to_string() -> String:
	var output = ""
	for move in moves_list:
		output += move._to_string()
		output += "\n"
	return output
