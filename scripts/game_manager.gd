extends Control
@export var moves_list: MovesList = preload("res://resources/moves/global_moves_list.tres")
@export var items_list: ItemsList = preload("res://resources/items/global_items_list.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensures different RNG every time the game runs
	randomize()

func get_move_by_name(move_to_find: String):
	for move in moves_list.moves:
		if move.move_name == move_to_find:
			return move
	push_error("MOVE NOT FOUND %s" % move_to_find)
	return ""
