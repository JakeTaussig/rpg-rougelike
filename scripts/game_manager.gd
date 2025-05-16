extends Control
var moves_list: Array[Move]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _init():
	var moves_list_temp = MovesList.new()
	moves_list_temp.initialize_moves()
	moves_list = moves_list_temp.moves_list
	print(moves_list)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
