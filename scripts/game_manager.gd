extends Control
@export var moves_list: MovesList = preload("res://assets/moves/global_moves_list.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensures different RNG every time the game runs
	randomize()
	pass
	
func get_move_by_name(move_to_find: String):
	for move in moves_list.moves:
		if move.move_name == move_to_find:
			return move
	push_error("MOVE NOT FOUND")
	return ""
