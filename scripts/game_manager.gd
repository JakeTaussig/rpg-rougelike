extends Control
@export var moves_list: MovesList = preload("res://resources/moves/global_moves_list.tres")
@export var items_list: ItemsList = preload("res://resources/items/global_items_list.tres")
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


const dark_blue_border_color = Color(0.071, 0.306, 0.537, 1.0)
const white = Color(1.0, 1.0, 1.0, 1.0)

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
	_hide_ui_elements()
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
	_show_player_and_enemy()
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
		_reset_ui_elements()


	_hide_player_and_enemy() # don't render the player and enemy on the room transition screen
	await get_tree().process_frame  # Ensure new enemy exists and is valid

	_update_ui_text()
	_show_ui_elements()
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
	apply_trinkets()
	player.selected_monster.hp = monster_hp


func apply_trinkets():
	var old_trinkets = player.selected_monster.trinkets

	player.selected_monster = player.selected_monster_backup.duplicate(true)

	player.selected_monster.trinkets = old_trinkets
	for trinket in player.selected_monster.trinkets:
		trinket.strategy.ApplyEffect(player.selected_monster)

	player.selected_monster.emit_trinkets_updated_signal()
	%TrinketShelf.render_trinkets()


func _reset_ui_elements():
	# reset the first event button to base styling
	var event_icon_button: Button = %FloorProgressDisplay.get_child(0)
	event_icon_button.set_pressed(false)
	event_icon_button.z_index = 1
	event_icon_button.add_theme_stylebox_override("normal", load("res://assets/styles/room_event_button_normal.tres"))
	event_icon_button.add_theme_stylebox_override("hover", load("res://assets/styles/room_event_button_normal.tres"))

	# reset the first event description to base styling
	var description_label: Label = %FloorProgressDescriptions.get_child(0)
	description_label.hide()
	description_label.add_theme_color_override("font_color", white)
	description_label.add_theme_stylebox_override("normal", load("res://assets/styles/shop_button.tres"))

	# Remove existing icons and labels for events
	for child in %FloorProgressDisplay.get_children():
		%FloorProgressDisplay.remove_child(child)
	for child in %FloorProgressDescriptions.get_children():
		%FloorProgressDescriptions.remove_child(child)

	for i in range(floor_event_count):
		var event = floor_events[i]
		var duplicate_icon_button: Button = event_icon_button.duplicate(DUPLICATE_USE_INSTANTIATION)
		var event_type = ""
		if event is Shop:
			duplicate_icon_button.icon = load("res://assets/sprites/room_icons/shop.png")
			event_type = "Shop"
		elif event is Battle:
			duplicate_icon_button.icon = load("res://assets/sprites/room_icons/battle.png")
			event_type = "Battle"

		%FloorProgressDisplay.add_child(duplicate_icon_button)

		var duplicate_label = description_label.duplicate()
		duplicate_label.text = "Room %d / %d: %s" % [i + 1, floor_event_count, event_type]
		%FloorProgressDescriptions.add_child(duplicate_label)

		# mouse_entered handler: show labels for events (excluding the next
		# upcoming event, which already has its label showing).
		duplicate_icon_button.mouse_entered.connect(func():
			if i < floor_event_index:
				duplicate_label.add_theme_stylebox_override("normal", load("res://assets/styles/shop_button.tres"))
				duplicate_label.add_theme_color_override("font_color", white)
			duplicate_label.show()
		)

		# mouse_exited handler: hide labels. for already completed events, make
		# the label the same color as the background to not affect layout
		duplicate_icon_button.mouse_exited.connect(func():
			if i > floor_event_index:
				duplicate_label.hide()
			if i < floor_event_index:
				duplicate_label.add_theme_stylebox_override("normal", load("res://assets/styles/shop_button_border_color.tres"))
				duplicate_label.add_theme_color_override("font_color", dark_blue_border_color)
		)


func _update_ui_text():
	var next_event = floor_events[0]
	var next_event_type = ""
	var next_event_icon
	if next_event is Shop:
		next_event_type = "Shop"
		next_event_icon = load("res://assets/sprites/room_icons/shop.png")
	if next_event is Battle:
		next_event_type = "Battle"
		next_event_icon = load("res://assets/sprites/room_icons/battle.png")

	%UpNext.text = "Up next: %s" % next_event_type
	%NextRoomIcon.texture = next_event_icon
	%FloorName.text = "Floor %d" % floor_number


# This function is intended to be called after an event has been unloaded and
# before floor_event_index has been incremented
func _hide_ui_elements():
	# press the icon button for the event, changing the background color
	%FloorProgressDisplay.get_child(floor_event_index).set_pressed(true)

	# Make the label for the recently unloaded event invisible
	var event_label: Label = %FloorProgressDescriptions.get_child(floor_event_index)
	event_label.add_theme_stylebox_override("normal", load("res://assets/styles/shop_button_border_color.tres"))
	event_label.add_theme_color_override("font_color", dark_blue_border_color)

	%FloorProgressDisplay.hide()
	%FloorProgressDescriptions.hide()
	%Title.hide()
	%UpNext.hide()
	%NextRoomPanel.hide()
	%FloorName.hide()


func _show_ui_elements():
	%FloorProgressDisplay.show()
	%FloorProgressDescriptions.show()
	%FloorProgressDescriptions.get_child(floor_event_index).show()
	%Title.show()
	%UpNext.show()
	%NextRoomPanel.show()
	%FloorName.show()

	# Make the button for the next event highlighted
	var event_button: Button = %FloorProgressDisplay.get_child(floor_event_index)
	event_button.add_theme_stylebox_override("normal", load("res://assets/styles/room_event_button_active.tres"))
	event_button.add_theme_stylebox_override("hover", load("res://assets/styles/room_event_button_active.tres"))
	event_button.z_index = 2

	# Show any trinkets the player has obtained since last time
	%TrinketShelf.render_trinkets()


func _hide_player_and_enemy():
	player.hide()
	enemy.hide()

func _show_player_and_enemy():
	player.show()
	enemy.show()
