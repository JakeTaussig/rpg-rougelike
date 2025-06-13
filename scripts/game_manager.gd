extends Control
@export var moves_list: MovesList = preload("res://assets/moves/global_moves_list.tres")
var floor_events = []
var current_battle: Battle



var player: BattleParticipant
var enemy: BattleParticipant

var battle_scene = preload("res://scenes/battle.tscn")
var battle_participant_scene := preload("res://scenes/battle_participant.tscn")
# var shop_scene = preload("res://scenes/shop.tscn") (future)

func start_game():
	# Called once to seed the random number generator
	randomize()
	player = %Player
	enemy = %Enemy
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

	current_battle.setup(enemy)
	add_child(current_battle)
	current_battle.connect("battle_ended", Callable(self, "_on_battle_ended"))

func _on_battle_ended(victory: bool):
	if not victory:
		# TODO: game over screen
		return
	_transition_events()

func _transition_events():
	await get_tree().create_timer(1.0).timeout
	current_battle.queue_free()
	# Eventually, we'll need a way of doing this procedurally.
	_create_new_enemy()
	_start_next_event()
	
func get_move_by_name(move_to_find: String):
	for move in moves_list.moves:
		if move.move_name == move_to_find:
			return move
			
func _create_new_enemy() -> void:
	var monsters = load_monsters_from_folder()
	var new_enemy_node = battle_participant_scene.instantiate()
	new_enemy_node.set_script(preload("res://scripts/enemy.gd"))
	# 2nd param = AI types 0 = RANDOM, 1 = AGGRESSIVE, 2 = HIGH_EV
	new_enemy_node.setup(monsters, 0)
	enemy = new_enemy_node
	
func load_monsters_from_folder(path: String = "res://assets/monsters") -> Array[Monster]:
	var monsters: Array[Monster] = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Could not open directory: " + path)
		return []

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var monster_path = path + "/" + file_name
			var monster_resource = load(monster_path)
			if monster_resource is Monster:
				monsters.append(monster_resource)
		file_name = dir.get_next()
	dir.list_dir_end()
	return monsters
	
	
