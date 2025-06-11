extends Control
@export var moves_list: MovesList = preload("res://assets/moves/global_moves_list.tres")
var floor_events = []
var current_battle: Battle

var battle_scene = preload("res://scenes/battle.tscn")
# var shop_scene = preload("res://scenes/shop.tscn") (future)

# Called when the node enters the scene tree for the first time.
func start_game():
	_generate_floor_events()
	_start_next_event()

func _generate_floor_events():
	for i in 2:
		var battle = battle_scene.instantiate()
		floor_events.push_back(battle)

func _start_next_event():
	if floor_events.is_empty():
		print("Floor complete!")
		# TODO: transition to next floor or win screen
		return

	# This will always be index 0, since we pop_front of floor_events whenever switching events. 
	var event = floor_events[0]
	if event is Battle:
		_run_battle()
	#elif event is Shop:
		#_run_shop(event.data)

func _run_battle():
	current_battle = floor_events.pop_front()
	add_child(current_battle)
	current_battle.connect("battle_ended", Callable(self, "_on_battle_ended"))

func _on_battle_ended(victory: bool):
	if victory:
		print("Battle won.")
		current_battle.queue_free()
		_start_next_event()
	else:
		print("Battle lost. Game over.")
		# TODO: game over screen
		return

	_show_transition_message()

func _show_transition_message():
	# Simple version
	print("Event complete. Proceeding...")
	await get_tree().create_timer(1.0).timeout
	_start_next_event()
	
func get_move_by_name(move_to_find: String):
	for move in moves_list.moves:
		if move.move_name == move_to_find:
			return move
	
