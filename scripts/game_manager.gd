extends Control
@export var moves_list: MovesList = preload("res://resources/moves/global_moves_list.tres")
@export var items_list: ItemsList = preload("res://resources/items/global_items_list.tres")
var trinkets_list: TrinketsList = TrinketsList.new()

var floor_number = 0
var floor_events = []
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


func start_game():
	# Called once to seed the random number generator
	randomize()
	_load_and_randomize_monsters()
	player = _create_player()
	enemy = _create_new_enemy()
	_load_and_randomize_monsters()
	_transition_events()


func _load_and_randomize_monsters():
	var dir := DirAccess.open("res://assets/monsters")
	if dir == null:
		push_error("Could not open monster directory")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var monster_path = "res://assets/monsters/" + file_name
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
	var progress_button: Button = %FloorProgressDisplay.get_child(0)
	progress_button.set_pressed(false)
	progress_button.z_index = 1
	progress_button.add_theme_stylebox_override("normal", load("res://assets/styles/shop_button.tres"))
	progress_button.add_theme_stylebox_override("hover", load("res://assets/styles/shop_button.tres"))


	for child in %FloorProgressDisplay.get_children():
		%FloorProgressDisplay.remove_child(child)

	for i in range(floor_event_count):
		%FloorProgressDisplay.add_child(progress_button.duplicate(DUPLICATE_USE_INSTANTIATION))



func _on_continue_button_pressed() -> void:
	_start_next_event()


func _start_next_event():
	%FloorProgressDisplay.get_child(floor_event_index).set_pressed(true)

	floor_event_index += 1

	# hide the panel in the containing the player's money amount
	%FloorProgressDisplay.hide()
	%Money.hide()

	# This will always be index 0, since we pop_front of floor_events whenever switching events.
	var event = floor_events[0]
	if event is Battle:
		_run_battle()
	elif event is Shop:
		_run_shop()

func _run_battle():
	current_battle = floor_events.pop_front()
	_show_player_and_enemy()
	current_battle.setup(player, enemy)
	add_child(current_battle)
	current_battle.connect("battle_ended", Callable(self, "_on_battle_ended"))

func _run_shop():
	current_shop = floor_events.pop_front()
	add_child(current_shop)
	current_shop.setup()
	current_shop.connect("shop_ended", Callable(self, "_transition_events"))

func _on_battle_ended(victory: bool):
	if not victory:
		# TODO: game over screen
		return
	_transition_events()


func _update_panel_text():
	%Money.text = "¶ %d" % GameManager.player.money

	var next_event = floor_events[0]
	var next_event_type = ""
	if next_event is Shop:
		next_event_type = "Shop"
	if next_event is Battle:
		next_event_type = "Battle"

	var player: BattleParticipant = get_node("Player")


	%PanelText.text = "Floor %d" % floor_number
	%PanelText.text += "\n\n"
	%PanelText.text += "Event %d" % (floor_event_index + 1)
	%PanelText.text += "\n\n"
	%PanelText.text += "Remaining Events: %d" % (floor_event_count)
	%PanelText.text += "\n\n"
	%PanelText.text += "Up next: %s" % next_event_type

func _hide_player_and_enemy():
	player.hide()
	enemy.hide()

func _show_player_and_enemy():
	player.show()
	enemy.show()

func _transition_events():
	if current_battle:
		current_battle.queue_free()
	if current_shop:
		current_shop.queue_free()

	if floor_events.is_empty():
		print("Floor complete!")
		floor_event_index = 0
		floor_number += 1
		_generate_floor_events()

	var progress_button: Button = %FloorProgressDisplay.get_child(floor_event_index)
	progress_button.add_theme_stylebox_override("normal", load("res://assets/styles/progress_button_active.tres"))
	progress_button.add_theme_stylebox_override("hover", load("res://assets/styles/progress_button_active.tres"))
	progress_button.z_index = 2
	%FloorProgressDisplay.show()

	# Eventually, we'll need a way of doing this procedurally.
	enemy = _create_new_enemy()

	_hide_player_and_enemy()
	await get_tree().process_frame  # Ensure new enemy exists and is valid

	_update_panel_text()
	%Money.show()
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
	new_player.money = 500

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


# This is a seperate function because it must be called from BattleOver.gd to display the correct information
func level_up_player_and_enemies():
	# Only the enemy stat multiplier increases, because the player stays the same, while the enemies are generated every time.
	enemy_level += 1
	player.selected_monster.level_up(player_stat_multiplier)
