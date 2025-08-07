extends Control
@export var moves_list: MovesList = preload("res://resources/moves/global_moves_list.tres")
var trinkets_list: TrinketsList = TrinketsList.new()

var floor_number = 0
var floor_events = []
# events are removed from floor_events after the player completes them. because
# of this, we need to store the # of events on the floor as they're generated
var floor_event_count = 0
var floor_event_index = 0

var current_battle: Battle
var current_shop: Shop

var player: BattleParticipant
var enemy: BattleParticipant

var battle_scene = preload("res://scenes/battle.tscn")
var battle_participant_scene := preload("res://scenes/battle_participant.tscn")
var shop_scene = preload("res://scenes/shop.tscn")

# All of the player's and enemy's stats will be multiplied by their respective value at the end of each floor
var player_stat_multiplier := 1.2
var enemy_stat_multiplier := 1.2
var enemy_level = 0

var randomized_monsters: Array[Monster] = []

@onready var global_ui_manager = %GlobalUIManager


func start_game():
	# Called once to seed the random number generator
	randomize()
	_load_and_randomize_monsters()
	player = _create_player()
	enemy = _create_new_enemy()
	_exit_current_event()


func _load_and_randomize_monsters():
	var dir := DirAccess.open("res://resources/monsters")
	if dir == null:
		push_error("Could not open monster directory")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var monster_path = "res://resources/monsters/" + file_name
			var monster_resource = load(monster_path)
			if monster_resource is Monster:
				monster_resource.randomize_stat_spread(monster_resource.base_stat_total, 10)
				monster_resource.randomize_moves()
				randomized_monsters.append(monster_resource)
		file_name = dir.get_next()
	dir.list_dir_end()


# generate all events for a floor.
func _generate_floor_events():
	var shop = shop_scene.instantiate()
	floor_events.push_back(shop)

	var battle = battle_scene.instantiate()
	floor_events.push_back(battle)

	floor_event_count = floor_events.size()


func _on_continue_button_pressed() -> void:
	global_ui_manager.hide_ui_elements()
	_start_next_event()


func _start_next_event():
	floor_event_index += 1

	# This will always be index 0, since we pop_front of floor_events whenever switching events.
	var event = floor_events[0]
	if event is Battle:
		_run_battle()
	elif event is Shop:
		_run_shop()


func _run_battle():
	current_battle = floor_events.pop_front()
	global_ui_manager.show_player_and_enemy()
	current_battle.setup(player, enemy)
	add_child(current_battle)
	current_battle.connect("battle_ended", Callable(self, "_on_battle_ended"))


func _run_shop():
	current_shop = floor_events.pop_front()
	add_child(current_shop)
	current_shop.setup()
	current_shop.connect("shop_ended", Callable(self, "_exit_current_event"))


func _on_battle_ended(victory: bool):
	if not victory:
		# TODO: game over screen
		return
	_exit_current_event()

func _exit_current_event():
	if current_battle:
		current_battle.queue_free()
		# Eventually, we'll need a way of doing this procedurally.
		enemy = _create_new_enemy()
	if current_shop:
		current_shop.queue_free()

	if floor_events.is_empty():
		print("Floor complete!")
		floor_event_index = 0
		floor_number += 1
		_generate_floor_events()
		global_ui_manager.reset_ui_elements()


	global_ui_manager.hide_player_and_enemy() # don't render the player and enemy on the room transition screen
	await get_tree().process_frame  # Ensure new enemy exists and is valid

	global_ui_manager.update_ui_text()
	global_ui_manager.show_ui_elements()

	%ContinueButton.disabled = false
	%ContinueButton.grab_focus()


func get_move_by_name(move_to_find: String):
	for move in moves_list.moves:
		if move.move_name == move_to_find:
			return move


func _create_player() -> BattleParticipant:
	var monster_index = randi() % randomized_monsters.size()
	var new_player = battle_participant_scene.instantiate()
	new_player.set_script(preload("res://scripts/battle_participant.gd"))
	new_player.setup_player(randomized_monsters[monster_index])
	self.add_child(new_player)
	new_player.name = "Player"
	new_player.prana = 500
	new_player.selected_monster_backup = new_player.selected_monster.duplicate(true)
	%TrinketShelf.trinkets = new_player.selected_monster.trinkets

	return new_player


func _create_new_enemy() -> BattleParticipant:
	var monsters = randomized_monsters
	var new_enemy = battle_participant_scene.instantiate()
	new_enemy.set_script(preload("res://scripts/enemy.gd"))
	# 2nd param = AI types 0 = RANDOM, 1 = AGGRESSIVE, 2 = HIGH_EV
	new_enemy.setup_enemy(monsters, 0, enemy_stat_multiplier, enemy_level)

	# Replace old enemy node in the scene
	if enemy:
		var old_enemy = get_node("Enemy")
		var parent = old_enemy.get_parent()
		parent.remove_child(old_enemy)
		old_enemy.queue_free()

	self.add_child(new_enemy)
	new_enemy.name = "Enemy"
	return new_enemy


func level_up_player_and_enemies():
	# Only the enemy stat multiplier increases, because the player stays the same, while the enemies are generated every time.
	enemy_level += 1
	var old_max_hp = player.selected_monster_backup.max_hp
	# Level up the backup so that trinkets don't effect the stats, then re-apply the trinket
	player.selected_monster_backup.level_up(player_stat_multiplier)
	# The HP gets reset to what the monster's hp was at the end of battle, plus the level up bonus
	var monster_hp = player.selected_monster.hp + (player.selected_monster_backup.max_hp - old_max_hp)
	var monster_moves = player.selected_monster.moves
	apply_trinkets()
	player.selected_monster.hp = monster_hp

	# The way we copy moves assumes that trinkets which modify the player's
	# moves (e.g. PP up) do not have effects that need to be applied every time
	# the player levels up
	player.selected_monster.moves = monster_moves


func apply_trinkets():
	var old_trinkets = player.selected_monster.trinkets

	player.selected_monster = player.selected_monster_backup.duplicate(true)

	player.selected_monster.trinkets = old_trinkets
	for trinket in player.selected_monster.trinkets:
		# Gets applied every time
		if not trinket.apply_once:
			trinket.strategy.ApplyEffect(player.selected_monster)

	player.selected_monster.emit_trinkets_updated_signal()
	%TrinketShelf.render_trinkets()
